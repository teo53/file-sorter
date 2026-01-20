import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../common/prisma/prisma.service';
// import Stripe from 'stripe';

@Injectable()
export class PaymentsService {
  // private stripe: Stripe | null = null;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    // const stripeKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    // if (stripeKey) {
    //   this.stripe = new Stripe(stripeKey, { apiVersion: '2023-10-16' });
    // }
  }

  // 결제 인텐트 생성 (Stripe)
  async createPaymentIntent(userId: string, artistId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { id: artistId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트를 찾을 수 없습니다.');
    }

    // if (!this.stripe) {
    //   throw new BadRequestException('결제 시스템이 설정되지 않았습니다.');
    // }

    // const paymentIntent = await this.stripe.paymentIntents.create({
    //   amount: artist.subscriptionPrice,
    //   currency: 'krw',
    //   metadata: {
    //     userId,
    //     artistId,
    //     type: 'subscription',
    //   },
    // });

    return {
      // clientSecret: paymentIntent.client_secret,
      clientSecret: 'mock_client_secret', // Mock for development
      amount: artist.subscriptionPrice,
      currency: 'KRW',
    };
  }

  // 내 결제 내역 조회
  async getMyPayments(
    userId: string,
    options: { page?: number; limit?: number },
  ) {
    const { page = 1, limit = 20 } = options;

    const [payments, total] = await Promise.all([
      this.prisma.payment.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
        include: {
          subscription: {
            include: {
              artistProfile: {
                select: {
                  id: true,
                  stageName: true,
                  profileImage: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.payment.count({ where: { userId } }),
    ]);

    return {
      data: payments.map((p) => ({
        id: p.id,
        type: p.type,
        status: p.status,
        amount: p.amount,
        currency: p.currency,
        createdAt: p.createdAt,
        artist: p.subscription?.artistProfile,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // 아티스트 정산 내역 조회
  async getArtistRevenue(artistUserId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    // Get total revenue
    const totalRevenue = await this.prisma.payment.aggregate({
      where: {
        subscription: { artistProfileId: artist.id },
        status: 'COMPLETED',
      },
      _sum: {
        artistRevenue: true,
      },
    });

    // Get unsettled revenue
    const unsettledRevenue = await this.prisma.payment.aggregate({
      where: {
        subscription: { artistProfileId: artist.id },
        status: 'COMPLETED',
        isSettled: false,
      },
      _sum: {
        artistRevenue: true,
      },
    });

    // Get monthly revenue for the last 6 months
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const monthlyPayments = await this.prisma.payment.findMany({
      where: {
        subscription: { artistProfileId: artist.id },
        status: 'COMPLETED',
        createdAt: { gte: sixMonthsAgo },
      },
      select: {
        artistRevenue: true,
        createdAt: true,
      },
    });

    // Group by month
    const monthlyRevenue = monthlyPayments.reduce(
      (acc, p) => {
        const month = p.createdAt.toISOString().substring(0, 7); // YYYY-MM
        acc[month] = (acc[month] || 0) + (p.artistRevenue || 0);
        return acc;
      },
      {} as Record<string, number>,
    );

    // Get recent settlements
    const settlements = await this.prisma.settlement.findMany({
      where: { artistProfileId: artist.id },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    return {
      totalRevenue: totalRevenue._sum.artistRevenue || 0,
      unsettledRevenue: unsettledRevenue._sum.artistRevenue || 0,
      monthlyRevenue,
      recentSettlements: settlements,
    };
  }

  // 정산 요청
  async requestSettlement(artistUserId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    if (!artist.bankAccount || !artist.bankName) {
      throw new BadRequestException(
        '정산 계좌 정보가 등록되지 않았습니다. 프로필에서 계좌 정보를 등록해주세요.',
      );
    }

    // Calculate unsettled amount
    const unsettledPayments = await this.prisma.payment.findMany({
      where: {
        subscription: { artistProfileId: artist.id },
        status: 'COMPLETED',
        isSettled: false,
      },
    });

    if (unsettledPayments.length === 0) {
      throw new BadRequestException('정산할 금액이 없습니다.');
    }

    const totalAmount = unsettledPayments.reduce(
      (sum, p) => sum + (p.artistRevenue || 0),
      0,
    );

    const platformFee = unsettledPayments.reduce(
      (sum, p) => sum + (p.platformFee || 0),
      0,
    );

    // Create settlement record
    const settlement = await this.prisma.settlement.create({
      data: {
        artistProfileId: artist.id,
        periodStart: new Date(
          Math.min(...unsettledPayments.map((p) => p.createdAt.getTime())),
        ),
        periodEnd: new Date(),
        totalRevenue: totalAmount + platformFee,
        platformFee,
        netAmount: totalAmount,
        status: 'PENDING',
      },
    });

    // Mark payments as settled
    await this.prisma.payment.updateMany({
      where: {
        id: { in: unsettledPayments.map((p) => p.id) },
      },
      data: {
        isSettled: true,
        settledAt: new Date(),
      },
    });

    return {
      settlementId: settlement.id,
      amount: totalAmount,
      message: '정산 요청이 완료되었습니다. 영업일 기준 3~5일 내에 입금됩니다.',
    };
  }

  // 정산 내역 조회
  async getSettlements(artistUserId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const settlements = await this.prisma.settlement.findMany({
      where: { artistProfileId: artist.id },
      orderBy: { createdAt: 'desc' },
    });

    return settlements;
  }

  // IAP 영수증 검증 (iOS/Android)
  async verifyIAPReceipt(
    userId: string,
    receipt: string,
    platform: 'ios' | 'android',
  ) {
    // TODO: Implement IAP receipt verification
    // For iOS: Use App Store Server API
    // For Android: Use Google Play Developer API

    return {
      valid: true,
      transactionId: 'mock_transaction_id',
      productId: 'subscription_monthly',
    };
  }
}
