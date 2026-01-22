import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateStoryDto } from './dto/create-story.dto';
import { ReactToStoryDto } from './dto/react-to-story.dto';
import { StoryVisibility } from '@prisma/client';

const STORY_DURATION_HOURS = 24; // 스토리 유효 시간

@Injectable()
export class StoriesService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  /**
   * 아티스트가 스토리 생성
   */
  async createStory(artistUserId: string, dto: CreateStoryDto) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    if (artist.status !== 'APPROVED') {
      throw new ForbiddenException('승인된 아티스트만 스토리를 올릴 수 있습니다.');
    }

    // 만료 시간 계산
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + STORY_DURATION_HOURS);

    const story = await this.prisma.story.create({
      data: {
        artistProfileId: artist.id,
        mediaType: dto.mediaType,
        mediaUrl: dto.mediaUrl,
        thumbnailUrl: dto.thumbnailUrl,
        textOverlay: dto.textOverlay,
        visibility: dto.visibility || StoryVisibility.PUBLIC,
        expiresAt,
      },
    });

    // 구독자에게 알림 전송 (선택적)
    if (dto.visibility !== StoryVisibility.SUBSCRIBERS) {
      // PUBLIC 스토리는 알림 안 보냄 (너무 많을 수 있음)
    } else {
      // SUBSCRIBERS 전용은 알림 발송
      const subscriptions = await this.prisma.subscription.findMany({
        where: {
          artistProfileId: artist.id,
          status: 'ACTIVE',
        },
        include: {
          fan: true,
        },
      });

      const notificationPromises = subscriptions
        .filter((sub) => sub.fan.pushEnabled)
        .map((sub) =>
          this.notificationsService.sendPushNotification(sub.fanId, {
            title: `${artist.stageName}님의 새 스토리`,
            body: dto.textOverlay || '새로운 스토리가 올라왔어요! 🌟',
            data: {
              type: 'NEW_STORY',
              artistId: artist.id,
              storyId: story.id,
            },
          }),
        );

      await Promise.allSettled(notificationPromises);
    }

    return {
      id: story.id,
      mediaType: story.mediaType,
      mediaUrl: story.mediaUrl,
      expiresAt: story.expiresAt,
      message: '스토리가 업로드되었습니다.',
    };
  }

  /**
   * 스토리 피드 조회 (팬용)
   */
  async getStoryFeed(fanUserId: string) {
    // 현재 구독 중인 아티스트 조회
    const subscriptions = await this.prisma.subscription.findMany({
      where: {
        fanId: fanUserId,
        status: 'ACTIVE',
      },
      select: {
        artistProfileId: true,
      },
    });

    const subscribedArtistIds = subscriptions.map((s) => s.artistProfileId);

    // 만료되지 않은 스토리 조회
    const now = new Date();
    const stories = await this.prisma.story.findMany({
      where: {
        expiresAt: { gt: now },
        OR: [
          // PUBLIC 스토리는 모두 볼 수 있음
          { visibility: StoryVisibility.PUBLIC },
          // SUBSCRIBERS 스토리는 구독자만
          {
            visibility: StoryVisibility.SUBSCRIBERS,
            artistProfileId: { in: subscribedArtistIds },
          },
        ],
      },
      include: {
        artistProfile: {
          select: {
            id: true,
            stageName: true,
            profileImage: true,
            category: true,
          },
        },
        views: {
          where: { userId: fanUserId },
          select: { id: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // 아티스트별로 그룹화
    const artistStoryMap = new Map<
      string,
      {
        artist: any;
        stories: any[];
        hasUnviewed: boolean;
        latestStoryAt: Date;
      }
    >();

    for (const story of stories) {
      const artistId = story.artistProfileId;
      const isViewed = story.views.length > 0;

      if (!artistStoryMap.has(artistId)) {
        artistStoryMap.set(artistId, {
          artist: story.artistProfile,
          stories: [],
          hasUnviewed: false,
          latestStoryAt: story.createdAt,
        });
      }

      const group = artistStoryMap.get(artistId)!;
      group.stories.push({
        id: story.id,
        mediaType: story.mediaType,
        mediaUrl: story.mediaUrl,
        thumbnailUrl: story.thumbnailUrl,
        textOverlay: story.textOverlay,
        isViewed,
        createdAt: story.createdAt,
        expiresAt: story.expiresAt,
      });

      if (!isViewed) {
        group.hasUnviewed = true;
      }
    }

    // 안 본 스토리가 있는 아티스트 우선, 그 다음 최신순
    const sortedGroups = Array.from(artistStoryMap.values()).sort((a, b) => {
      if (a.hasUnviewed && !b.hasUnviewed) return -1;
      if (!a.hasUnviewed && b.hasUnviewed) return 1;
      return b.latestStoryAt.getTime() - a.latestStoryAt.getTime();
    });

    return sortedGroups.map((group) => ({
      artist: group.artist,
      stories: group.stories,
      hasUnviewed: group.hasUnviewed,
    }));
  }

  /**
   * 특정 아티스트의 스토리 조회
   */
  async getArtistStories(fanUserId: string, artistProfileId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { id: artistProfileId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트를 찾을 수 없습니다.');
    }

    // 구독 여부 확인
    const subscription = await this.prisma.subscription.findUnique({
      where: {
        fanId_artistProfileId: {
          fanId: fanUserId,
          artistProfileId,
        },
      },
    });

    const isSubscriber = subscription?.status === 'ACTIVE';

    const now = new Date();
    const whereClause: any = {
      artistProfileId,
      expiresAt: { gt: now },
    };

    // 비구독자는 PUBLIC만
    if (!isSubscriber) {
      whereClause.visibility = StoryVisibility.PUBLIC;
    }

    const stories = await this.prisma.story.findMany({
      where: whereClause,
      include: {
        views: {
          where: { userId: fanUserId },
          select: { id: true },
        },
      },
      orderBy: { createdAt: 'asc' }, // 오래된 것부터 (스토리 순서대로)
    });

    return {
      artist: {
        id: artist.id,
        stageName: artist.stageName,
        profileImage: artist.profileImage,
      },
      stories: stories.map((story) => ({
        id: story.id,
        mediaType: story.mediaType,
        mediaUrl: story.mediaUrl,
        thumbnailUrl: story.thumbnailUrl,
        textOverlay: story.textOverlay,
        isViewed: story.views.length > 0,
        createdAt: story.createdAt,
        expiresAt: story.expiresAt,
      })),
    };
  }

  /**
   * 스토리 조회 기록
   */
  async markAsViewed(fanUserId: string, storyId: string) {
    const story = await this.prisma.story.findUnique({
      where: { id: storyId },
    });

    if (!story) {
      throw new NotFoundException('스토리를 찾을 수 없습니다.');
    }

    // 이미 조회했는지 확인
    const existingView = await this.prisma.storyView.findUnique({
      where: {
        storyId_userId: {
          storyId,
          userId: fanUserId,
        },
      },
    });

    if (existingView) {
      return { alreadyViewed: true };
    }

    await this.prisma.storyView.create({
      data: {
        storyId,
        userId: fanUserId,
      },
    });

    return { viewed: true };
  }

  /**
   * 스토리에 리액션
   */
  async reactToStory(fanUserId: string, storyId: string, dto: ReactToStoryDto) {
    const story = await this.prisma.story.findUnique({
      where: { id: storyId },
      include: {
        artistProfile: {
          include: { user: true },
        },
      },
    });

    if (!story) {
      throw new NotFoundException('스토리를 찾을 수 없습니다.');
    }

    // 기존 리액션 확인 (upsert)
    const reaction = await this.prisma.storyReaction.upsert({
      where: {
        storyId_userId: {
          storyId,
          userId: fanUserId,
        },
      },
      update: {
        emoji: dto.emoji,
      },
      create: {
        storyId,
        userId: fanUserId,
        emoji: dto.emoji,
      },
    });

    // 아티스트에게 알림 (첫 리액션인 경우만)
    const reactionCount = await this.prisma.storyReaction.count({
      where: { storyId },
    });

    if (reactionCount === 1 && story.artistProfile.user.pushEnabled) {
      const fan = await this.prisma.user.findUnique({
        where: { id: fanUserId },
        select: { nickname: true },
      });

      await this.notificationsService.sendPushNotification(
        story.artistProfile.userId,
        {
          title: '스토리 리액션',
          body: `${fan?.nickname || '팬'}님이 스토리에 ${dto.emoji} 반응을 남겼어요!`,
          data: {
            type: 'STORY_REACTION',
            storyId,
          },
        },
      );
    }

    return {
      reactionId: reaction.id,
      emoji: reaction.emoji,
    };
  }

  /**
   * 아티스트의 스토리 통계
   */
  async getMyStoryStats(artistUserId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const now = new Date();

    // 활성 스토리 (만료 안 됨)
    const activeStories = await this.prisma.story.findMany({
      where: {
        artistProfileId: artist.id,
        expiresAt: { gt: now },
      },
      include: {
        _count: {
          select: {
            views: true,
            reactions: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // 전체 통계
    const [totalViews, totalReactions, totalStories] = await Promise.all([
      this.prisma.storyView.count({
        where: {
          story: { artistProfileId: artist.id },
        },
      }),
      this.prisma.storyReaction.count({
        where: {
          story: { artistProfileId: artist.id },
        },
      }),
      this.prisma.story.count({
        where: { artistProfileId: artist.id },
      }),
    ]);

    return {
      activeStories: activeStories.map((story) => ({
        id: story.id,
        mediaType: story.mediaType,
        thumbnailUrl: story.thumbnailUrl || story.mediaUrl,
        textOverlay: story.textOverlay,
        viewCount: story._count.views,
        reactionCount: story._count.reactions,
        createdAt: story.createdAt,
        expiresAt: story.expiresAt,
      })),
      summary: {
        activeCount: activeStories.length,
        totalStories,
        totalViews,
        totalReactions,
      },
    };
  }

  /**
   * 스토리 삭제
   */
  async deleteStory(artistUserId: string, storyId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const story = await this.prisma.story.findUnique({
      where: { id: storyId },
    });

    if (!story) {
      throw new NotFoundException('스토리를 찾을 수 없습니다.');
    }

    if (story.artistProfileId !== artist.id) {
      throw new ForbiddenException('이 스토리를 삭제할 권한이 없습니다.');
    }

    await this.prisma.story.delete({
      where: { id: storyId },
    });

    return { deleted: true };
  }
}
