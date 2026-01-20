import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { SubscribeDto } from './dto/subscribe.dto';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SubscriptionsService {
  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {}

  // 아티스트 구독하기
  async subscribe(fanId: string, dto: SubscribeDto) {
    // Check if artist exists
    const artist = await this.prisma.artistProfile.findUnique({
      where: { id: dto.artistId },
      include: { user: true },
    });

    if (!artist || artist.status !== 'APPROVED') {
      throw new NotFoundException('아티스트를 찾을 수 없습니다.');
    }

    // Check if already subscribed
    const existingSubscription = await this.prisma.subscription.findFirst({
      where: {
        fanId,
        artistProfileId: dto.artistId,
        status: 'ACTIVE',
      },
    });

    if (existingSubscription) {
      throw new ConflictException('이미 구독 중인 아티스트입니다.');
    }

    // Calculate platform fee
    const platformFeePercent = this.configService.get<number>(
      'PLATFORM_FEE_PERCENT',
      20,
    );
    const platformFee = Math.floor(
      (artist.subscriptionPrice * platformFeePercent) / 100,
    );
    const artistRevenue = artist.subscriptionPrice - platformFee;

    // Create subscription with chat room
    const subscription = await this.prisma.$transaction(async (tx) => {
      // Create subscription
      const sub = await tx.subscription.create({
        data: {
          fanId,
          artistProfileId: dto.artistId,
          price: artist.subscriptionPrice,
          status: 'ACTIVE',
          startDate: new Date(),
          renewalDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
          autoRenewal: true,
        },
      });

      // Create chat room
      const chatRoom = await tx.chatRoom.create({
        data: {
          subscriptionId: sub.id,
        },
      });

      // Create payment record
      await tx.payment.create({
        data: {
          userId: fanId,
          subscriptionId: sub.id,
          type: 'SUBSCRIPTION',
          status: 'COMPLETED',
          amount: artist.subscriptionPrice,
          paymentMethod: dto.paymentMethod || 'stripe',
          platformFee,
          artistRevenue,
        },
      });

      // Increment subscriber count
      await tx.artistProfile.update({
        where: { id: dto.artistId },
        data: {
          subscriberCount: { increment: 1 },
        },
      });

      // Get fan info for welcome message
      const fan = await tx.user.findUnique({
        where: { id: fanId },
      });

      // Send welcome message if set
      if (artist.welcomeMessage) {
        const personalizedMessage = artist.welcomeMessage.replace(
          /\[name\]/g,
          fan?.nickname || '팬',
        );

        await tx.message.create({
          data: {
            chatRoomId: chatRoom.id,
            senderType: 'SYSTEM',
            artistProfileId: dto.artistId,
            type: 'TEXT',
            content: personalizedMessage,
            originalContent: artist.welcomeMessage,
          },
        });
      }

      return sub;
    });

    return {
      subscriptionId: subscription.id,
      message: '구독이 완료되었습니다!',
      artistName: artist.stageName,
    };
  }

  // 구독 취소
  async cancel(fanId: string, subscriptionId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: {
        id: subscriptionId,
        fanId,
        status: 'ACTIVE',
      },
      include: {
        artistProfile: true,
      },
    });

    if (!subscription) {
      throw new NotFoundException('구독 정보를 찾을 수 없습니다.');
    }

    await this.prisma.$transaction(async (tx) => {
      // Update subscription status
      await tx.subscription.update({
        where: { id: subscriptionId },
        data: {
          status: 'CANCELLED',
          autoRenewal: false,
          cancelledAt: new Date(),
        },
      });

      // Decrement subscriber count
      await tx.artistProfile.update({
        where: { id: subscription.artistProfileId },
        data: {
          subscriberCount: { decrement: 1 },
        },
      });
    });

    return {
      message: '구독이 취소되었습니다.',
      endDate: subscription.renewalDate,
    };
  }

  // 구독 상세 조회
  async findOne(fanId: string, subscriptionId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: {
        id: subscriptionId,
        fanId,
      },
      include: {
        artistProfile: {
          include: {
            user: {
              select: {
                id: true,
                nickname: true,
                profileImage: true,
              },
            },
          },
        },
        chatRoom: true,
      },
    });

    if (!subscription) {
      throw new NotFoundException('구독 정보를 찾을 수 없습니다.');
    }

    // Calculate subscribed days
    const subscribedDays = Math.floor(
      (Date.now() - subscription.startDate.getTime()) / (1000 * 60 * 60 * 24),
    );

    return {
      id: subscription.id,
      status: subscription.status,
      price: subscription.price,
      startDate: subscription.startDate,
      renewalDate: subscription.renewalDate,
      subscribedDays,
      autoRenewal: subscription.autoRenewal,
      chatRoomId: subscription.chatRoom?.id,
      artist: {
        id: subscription.artistProfile.id,
        stageName: subscription.artistProfile.stageName,
        profileImage: subscription.artistProfile.profileImage,
        category: subscription.artistProfile.category,
      },
    };
  }

  // 내 구독 목록
  async findMySubscriptions(fanId: string) {
    const subscriptions = await this.prisma.subscription.findMany({
      where: { fanId },
      include: {
        artistProfile: {
          include: {
            user: {
              select: {
                id: true,
                nickname: true,
                profileImage: true,
              },
            },
          },
        },
        chatRoom: {
          include: {
            messages: {
              orderBy: { createdAt: 'desc' },
              take: 1,
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return subscriptions.map((sub) => {
      const subscribedDays = Math.floor(
        (Date.now() - sub.startDate.getTime()) / (1000 * 60 * 60 * 24),
      );

      const lastMessage = sub.chatRoom?.messages[0];

      return {
        id: sub.id,
        status: sub.status,
        startDate: sub.startDate,
        subscribedDays,
        chatRoomId: sub.chatRoom?.id,
        lastMessage: lastMessage
          ? {
              content:
                lastMessage.type === 'TEXT'
                  ? lastMessage.content.substring(0, 50)
                  : `[${lastMessage.type}]`,
              createdAt: lastMessage.createdAt,
            }
          : null,
        artist: {
          id: sub.artistProfile.id,
          stageName: sub.artistProfile.stageName,
          profileImage: sub.artistProfile.profileImage,
          category: sub.artistProfile.category,
        },
      };
    });
  }

  // 아티스트의 구독자 목록
  async getSubscribers(artistUserId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const subscriptions = await this.prisma.subscription.findMany({
      where: {
        artistProfileId: artist.id,
        status: 'ACTIVE',
      },
      include: {
        fan: {
          select: {
            id: true,
            nickname: true,
            profileImage: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return subscriptions.map((sub) => ({
      subscriptionId: sub.id,
      subscribedAt: sub.startDate,
      subscribedDays: Math.floor(
        (Date.now() - sub.startDate.getTime()) / (1000 * 60 * 60 * 24),
      ),
      fan: sub.fan,
    }));
  }

  // 구독일 업데이트 (크론잡용)
  async updateSubscribedDays() {
    const activeSubscriptions = await this.prisma.subscription.findMany({
      where: { status: 'ACTIVE' },
    });

    for (const sub of activeSubscriptions) {
      const days = Math.floor(
        (Date.now() - sub.startDate.getTime()) / (1000 * 60 * 60 * 24),
      );

      await this.prisma.subscription.update({
        where: { id: sub.id },
        data: { subscribedDays: days },
      });
    }
  }
}
