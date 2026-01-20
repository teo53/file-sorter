import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateArtistProfileDto } from './dto/create-artist-profile.dto';
import { UpdateArtistProfileDto } from './dto/update-artist-profile.dto';
import { ArtistCategory, ArtistStatus, UserRole } from '@prisma/client';

@Injectable()
export class ArtistsService {
  constructor(private prisma: PrismaService) {}

  // 아티스트 프로필 생성 (아티스트 신청)
  async createProfile(userId: string, dto: CreateArtistProfileDto) {
    // Check if user already has artist profile
    const existingProfile = await this.prisma.artistProfile.findUnique({
      where: { userId },
    });

    if (existingProfile) {
      throw new BadRequestException('이미 아티스트 프로필이 존재합니다.');
    }

    // Create artist profile
    const profile = await this.prisma.artistProfile.create({
      data: {
        userId,
        stageName: dto.stageName,
        realName: dto.realName,
        bio: dto.bio,
        category: dto.category,
        profileImage: dto.profileImage,
        coverImage: dto.coverImage,
        twitterHandle: dto.twitterHandle,
        instagramHandle: dto.instagramHandle,
        youtubeChannel: dto.youtubeChannel,
        tiktokHandle: dto.tiktokHandle,
        subscriptionPrice: dto.subscriptionPrice || 4900,
        welcomeMessage: dto.welcomeMessage,
        fandomName: dto.fandomName,
        status: ArtistStatus.PENDING,
      },
    });

    // Update user role to ARTIST
    await this.prisma.user.update({
      where: { id: userId },
      data: { role: UserRole.ARTIST },
    });

    return profile;
  }

  // 아티스트 프로필 수정
  async updateProfile(userId: string, dto: UpdateArtistProfileDto) {
    const profile = await this.prisma.artistProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    return this.prisma.artistProfile.update({
      where: { userId },
      data: {
        stageName: dto.stageName,
        bio: dto.bio,
        category: dto.category,
        profileImage: dto.profileImage,
        coverImage: dto.coverImage,
        twitterHandle: dto.twitterHandle,
        instagramHandle: dto.instagramHandle,
        youtubeChannel: dto.youtubeChannel,
        tiktokHandle: dto.tiktokHandle,
        subscriptionPrice: dto.subscriptionPrice,
        welcomeMessage: dto.welcomeMessage,
        fandomName: dto.fandomName,
      },
    });
  }

  // 아티스트 목록 조회 (팬용)
  async findAll(options: {
    category?: ArtistCategory;
    search?: string;
    page?: number;
    limit?: number;
    sortBy?: 'popular' | 'new' | 'name';
  }) {
    const { category, search, page = 1, limit = 20, sortBy = 'popular' } = options;

    const where: any = {
      status: ArtistStatus.APPROVED,
    };

    if (category) {
      where.category = category;
    }

    if (search) {
      where.OR = [
        { stageName: { contains: search, mode: 'insensitive' } },
        { bio: { contains: search, mode: 'insensitive' } },
      ];
    }

    let orderBy: any = {};
    switch (sortBy) {
      case 'popular':
        orderBy = { subscriberCount: 'desc' };
        break;
      case 'new':
        orderBy = { createdAt: 'desc' };
        break;
      case 'name':
        orderBy = { stageName: 'asc' };
        break;
    }

    const [artists, total] = await Promise.all([
      this.prisma.artistProfile.findMany({
        where,
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
        include: {
          user: {
            select: {
              id: true,
              nickname: true,
              profileImage: true,
            },
          },
        },
      }),
      this.prisma.artistProfile.count({ where }),
    ]);

    return {
      data: artists.map((artist) => ({
        id: artist.id,
        stageName: artist.stageName,
        bio: artist.bio,
        category: artist.category,
        profileImage: artist.profileImage,
        coverImage: artist.coverImage,
        subscriberCount: artist.subscriberCount,
        subscriptionPrice: artist.subscriptionPrice,
        twitterHandle: artist.twitterHandle,
        instagramHandle: artist.instagramHandle,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // 아티스트 상세 조회
  async findOne(artistId: string, currentUserId?: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { id: artistId },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            profileImage: true,
          },
        },
      },
    });

    if (!artist || artist.status !== ArtistStatus.APPROVED) {
      throw new NotFoundException('아티스트를 찾을 수 없습니다.');
    }

    // Check if current user is subscribed
    let isSubscribed = false;
    let subscription = null;

    if (currentUserId) {
      const sub = await this.prisma.subscription.findFirst({
        where: {
          fanId: currentUserId,
          artistProfileId: artistId,
          status: 'ACTIVE',
        },
      });

      if (sub) {
        isSubscribed = true;
        subscription = {
          id: sub.id,
          startDate: sub.startDate,
          subscribedDays: sub.subscribedDays,
        };
      }
    }

    return {
      id: artist.id,
      stageName: artist.stageName,
      bio: artist.bio,
      category: artist.category,
      profileImage: artist.profileImage,
      coverImage: artist.coverImage,
      subscriberCount: artist.subscriberCount,
      subscriptionPrice: artist.subscriptionPrice,
      fandomName: artist.fandomName,
      twitterHandle: artist.twitterHandle,
      instagramHandle: artist.instagramHandle,
      youtubeChannel: artist.youtubeChannel,
      tiktokHandle: artist.tiktokHandle,
      isSubscribed,
      subscription,
    };
  }

  // 내 아티스트 프로필 조회
  async getMyProfile(userId: string) {
    const profile = await this.prisma.artistProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            nickname: true,
          },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('아티스트 프로필이 없습니다.');
    }

    return profile;
  }

  // 아티스트 대시보드 통계
  async getDashboardStats(userId: string) {
    const profile = await this.prisma.artistProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('아티스트 프로필이 없습니다.');
    }

    const [
      totalSubscribers,
      activeSubscribers,
      totalMessages,
      totalRevenue,
      recentSubscribers,
    ] = await Promise.all([
      // Total subscribers (all time)
      this.prisma.subscription.count({
        where: { artistProfileId: profile.id },
      }),
      // Active subscribers
      this.prisma.subscription.count({
        where: {
          artistProfileId: profile.id,
          status: 'ACTIVE',
        },
      }),
      // Total messages sent
      this.prisma.broadcastMessage.count({
        where: { artistProfileId: profile.id },
      }),
      // Total revenue
      this.prisma.payment.aggregate({
        where: {
          subscription: {
            artistProfileId: profile.id,
          },
          status: 'COMPLETED',
        },
        _sum: {
          artistRevenue: true,
        },
      }),
      // Recent subscribers (last 7 days)
      this.prisma.subscription.count({
        where: {
          artistProfileId: profile.id,
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
          },
        },
      }),
    ]);

    return {
      totalSubscribers,
      activeSubscribers,
      totalMessages,
      totalRevenue: totalRevenue._sum.artistRevenue || 0,
      recentSubscribers,
      subscriptionPrice: profile.subscriptionPrice,
    };
  }

  // 아티스트 승인 (관리자용)
  async approveArtist(artistId: string) {
    return this.prisma.artistProfile.update({
      where: { id: artistId },
      data: {
        status: ArtistStatus.APPROVED,
        approvedAt: new Date(),
      },
    });
  }

  // 아티스트 거절 (관리자용)
  async rejectArtist(artistId: string) {
    return this.prisma.artistProfile.update({
      where: { id: artistId },
      data: {
        status: ArtistStatus.REJECTED,
      },
    });
  }
}
