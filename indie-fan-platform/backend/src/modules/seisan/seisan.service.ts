import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateSeisanRequestDto } from './dto/create-seisan-request.dto';
import { RespondSeisanDto } from './dto/respond-seisan.dto';
import { SeisanStatus } from '@prisma/client';

// 가격-글자수 매핑
const TIER_MAP: Record<number, { textLimit: number }> = {
  3000: { textLimit: 50 },
  5000: { textLimit: 120 },
  10000: { textLimit: 300 },
  20000: { textLimit: 600 },
};

const VOICE_ADDITIONAL_PRICE = 10000; // 음성 옵션 추가 금액
const VOICE_LIMIT_SEC = 20; // 음성 제한 시간 (초)
const EXPIRATION_HOURS = 72; // 응답 만료 시간

@Injectable()
export class SeisanService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  /**
   * 팬이 정산 요청 생성
   */
  async createRequest(fanUserId: string, dto: CreateSeisanRequestDto) {
    // 아티스트 프로필 확인
    const artistProfile = await this.prisma.artistProfile.findUnique({
      where: { id: dto.artistProfileId },
      include: { user: true },
    });

    if (!artistProfile) {
      throw new NotFoundException('아티스트를 찾을 수 없습니다.');
    }

    if (artistProfile.status !== 'APPROVED') {
      throw new BadRequestException('현재 정산을 받을 수 없는 아티스트입니다.');
    }

    // 가격 티어 검증
    const tier = TIER_MAP[dto.offerAmount];
    if (!tier) {
      throw new BadRequestException(
        '유효한 금액을 선택해주세요 (3000, 5000, 10000, 20000원)',
      );
    }

    // 요청 메시지 글자수 검증
    if (dto.requestMessage.length > 500) {
      throw new BadRequestException('요청 메시지는 500자까지 가능합니다.');
    }

    // 총 금액 계산
    const totalAmount = dto.voiceOption
      ? dto.offerAmount + VOICE_ADDITIONAL_PRICE
      : dto.offerAmount;

    // 기존 스레드 찾기 또는 생성
    let thread = await this.prisma.seisanThread.findUnique({
      where: {
        fanId_artistProfileId: {
          fanId: fanUserId,
          artistProfileId: dto.artistProfileId,
        },
      },
    });

    if (!thread) {
      thread = await this.prisma.seisanThread.create({
        data: {
          fanId: fanUserId,
          artistProfileId: dto.artistProfileId,
        },
      });
    }

    // 만료 시간 계산
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + EXPIRATION_HOURS);

    // 정산 요청 생성
    const seisanRequest = await this.prisma.seisanRequest.create({
      data: {
        threadId: thread.id,
        fanId: fanUserId,
        artistProfileId: dto.artistProfileId,
        offerAmount: totalAmount,
        textLimit: tier.textLimit,
        voiceOption: dto.voiceOption || false,
        voiceLimitSec: dto.voiceOption ? VOICE_LIMIT_SEC : null,
        requestMessage: dto.requestMessage,
        chekiImageUrl: dto.chekiImageUrl,
        expiresAt,
      },
      include: {
        fan: {
          select: {
            id: true,
            nickname: true,
            profileImage: true,
          },
        },
        artistProfile: {
          select: {
            id: true,
            stageName: true,
            profileImage: true,
          },
        },
      },
    });

    // TODO: 결제 처리 (Payment 생성)

    // 아티스트에게 알림 전송
    if (artistProfile.user.pushEnabled) {
      await this.notificationsService.sendPushNotification(
        artistProfile.userId,
        {
          title: '새로운 정산 요청',
          body: `${seisanRequest.fan.nickname}님이 정산을 요청했어요!`,
          data: {
            type: 'SEISAN_REQUEST',
            requestId: seisanRequest.id,
          },
        },
      );
    }

    return {
      id: seisanRequest.id,
      amount: totalAmount,
      textLimit: tier.textLimit,
      voiceOption: dto.voiceOption || false,
      voiceLimitSec: dto.voiceOption ? VOICE_LIMIT_SEC : null,
      expiresAt,
      artist: seisanRequest.artistProfile,
      message: '정산 요청이 전송되었습니다.',
    };
  }

  /**
   * 팬의 정산 요청 목록 조회
   */
  async getMyRequests(
    fanUserId: string,
    options: { page?: number; limit?: number; status?: SeisanStatus },
  ) {
    const { page = 1, limit = 20, status } = options;

    const where: any = { fanId: fanUserId };
    if (status) {
      where.status = status;
    }

    const [requests, total] = await Promise.all([
      this.prisma.seisanRequest.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
        include: {
          artistProfile: {
            select: {
              id: true,
              stageName: true,
              profileImage: true,
              category: true,
            },
          },
        },
      }),
      this.prisma.seisanRequest.count({ where }),
    ]);

    return {
      data: requests.map((req) => ({
        id: req.id,
        amount: req.offerAmount,
        textLimit: req.textLimit,
        voiceOption: req.voiceOption,
        requestMessage: req.requestMessage.substring(0, 100),
        status: req.status,
        hasResponse: req.status === 'RESPONDED',
        createdAt: req.createdAt,
        respondedAt: req.respondedAt,
        expiresAt: req.expiresAt,
        artist: req.artistProfile,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * 정산 상세 조회 (팬/아티스트 공용)
   */
  async getRequestDetail(userId: string, requestId: string) {
    const request = await this.prisma.seisanRequest.findUnique({
      where: { id: requestId },
      include: {
        fan: {
          select: {
            id: true,
            nickname: true,
            profileImage: true,
          },
        },
        artistProfile: {
          select: {
            id: true,
            stageName: true,
            profileImage: true,
            category: true,
            userId: true,
          },
        },
      },
    });

    if (!request) {
      throw new NotFoundException('정산 요청을 찾을 수 없습니다.');
    }

    // 접근 권한 확인 (팬 또는 해당 아티스트만)
    if (request.fanId !== userId && request.artistProfile.userId !== userId) {
      throw new ForbiddenException('이 정산에 접근할 권한이 없습니다.');
    }

    const isFan = request.fanId === userId;

    return {
      id: request.id,
      amount: request.offerAmount,
      textLimit: request.textLimit,
      voiceOption: request.voiceOption,
      voiceLimitSec: request.voiceLimitSec,
      requestMessage: request.requestMessage,
      chekiImageUrl: request.chekiImageUrl,
      status: request.status,
      responseText: request.responseText,
      responseVoiceUrl: request.responseVoiceUrl,
      createdAt: request.createdAt,
      respondedAt: request.respondedAt,
      expiresAt: request.expiresAt,
      fan: isFan ? null : request.fan, // 아티스트 뷰에서만 팬 정보 표시
      artist: isFan ? request.artistProfile : null, // 팬 뷰에서만 아티스트 정보 표시
    };
  }

  /**
   * 아티스트의 대기 큐 조회
   */
  async getPendingQueue(
    artistUserId: string,
    options: { page?: number; limit?: number },
  ) {
    const { page = 1, limit = 20 } = options;

    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const where = {
      artistProfileId: artist.id,
      status: SeisanStatus.PENDING,
      expiresAt: { gt: new Date() }, // 만료되지 않은 것만
    };

    const [requests, total] = await Promise.all([
      this.prisma.seisanRequest.findMany({
        where,
        orderBy: { createdAt: 'asc' }, // 오래된 것부터 (FIFO)
        skip: (page - 1) * limit,
        take: limit,
        include: {
          fan: {
            select: {
              id: true,
              nickname: true,
              profileImage: true,
            },
          },
        },
      }),
      this.prisma.seisanRequest.count({ where }),
    ]);

    return {
      data: requests.map((req) => ({
        id: req.id,
        amount: req.offerAmount,
        textLimit: req.textLimit,
        voiceOption: req.voiceOption,
        voiceLimitSec: req.voiceLimitSec,
        requestMessage: req.requestMessage,
        chekiImageUrl: req.chekiImageUrl,
        createdAt: req.createdAt,
        expiresAt: req.expiresAt,
        fan: req.fan,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * 아티스트가 정산 응답
   */
  async respondToRequest(
    artistUserId: string,
    requestId: string,
    dto: RespondSeisanDto,
  ) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const request = await this.prisma.seisanRequest.findUnique({
      where: { id: requestId },
      include: {
        fan: true,
      },
    });

    if (!request) {
      throw new NotFoundException('정산 요청을 찾을 수 없습니다.');
    }

    if (request.artistProfileId !== artist.id) {
      throw new ForbiddenException('이 정산에 응답할 권한이 없습니다.');
    }

    if (request.status !== 'PENDING') {
      throw new BadRequestException('이미 응답했거나 만료된 정산입니다.');
    }

    // 만료 확인
    if (request.expiresAt && new Date() > request.expiresAt) {
      // 만료 상태로 업데이트
      await this.prisma.seisanRequest.update({
        where: { id: requestId },
        data: { status: SeisanStatus.EXPIRED },
      });
      throw new BadRequestException('만료된 정산 요청입니다.');
    }

    // 응답 글자수 검증
    if (dto.responseText.length > request.textLimit) {
      throw new BadRequestException(
        `응답은 ${request.textLimit}자까지 가능합니다. (현재 ${dto.responseText.length}자)`,
      );
    }

    // 음성 옵션 확인
    if (dto.responseVoiceUrl && !request.voiceOption) {
      throw new BadRequestException(
        '이 정산은 음성 메시지 옵션이 없습니다.',
      );
    }

    // 응답 저장
    const updatedRequest = await this.prisma.seisanRequest.update({
      where: { id: requestId },
      data: {
        status: SeisanStatus.RESPONDED,
        responseText: dto.responseText,
        responseVoiceUrl: dto.responseVoiceUrl,
        respondedAt: new Date(),
      },
    });

    // 팬에게 알림 전송
    if (request.fan.pushEnabled) {
      await this.notificationsService.sendPushNotification(request.fanId, {
        title: `${artist.stageName}님의 답장이 도착했어요!`,
        body: '특별한 정산을 열어보세요 💌',
        data: {
          type: 'SEISAN_RESPONSE',
          requestId: request.id,
        },
      });
    }

    return {
      id: updatedRequest.id,
      status: updatedRequest.status,
      respondedAt: updatedRequest.respondedAt,
      message: '정산 응답이 완료되었습니다.',
    };
  }

  /**
   * 아티스트의 정산 통계 조회
   */
  async getSeisanStats(artistUserId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const [totalRequests, pendingCount, respondedCount, totalRevenue] =
      await Promise.all([
        this.prisma.seisanRequest.count({
          where: { artistProfileId: artist.id },
        }),
        this.prisma.seisanRequest.count({
          where: {
            artistProfileId: artist.id,
            status: SeisanStatus.PENDING,
            expiresAt: { gt: new Date() },
          },
        }),
        this.prisma.seisanRequest.count({
          where: {
            artistProfileId: artist.id,
            status: SeisanStatus.RESPONDED,
          },
        }),
        this.prisma.seisanRequest.aggregate({
          where: {
            artistProfileId: artist.id,
            status: SeisanStatus.RESPONDED,
          },
          _sum: { offerAmount: true },
        }),
      ]);

    return {
      totalRequests,
      pendingCount,
      respondedCount,
      expiredCount: totalRequests - pendingCount - respondedCount,
      totalRevenue: totalRevenue._sum.offerAmount || 0,
      responseRate:
        totalRequests > 0
          ? Math.round((respondedCount / totalRequests) * 100)
          : 0,
    };
  }
}
