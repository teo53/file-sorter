import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
      include: {
        artistProfile: true,
      },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async updateProfile(userId: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.findById(userId);

    if (!user) {
      throw new NotFoundException('사용자를 찾을 수 없습니다.');
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        nickname: dto.nickname,
        profileImage: dto.profileImage,
        gender: dto.gender,
        birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
        phoneNumber: dto.phoneNumber,
        pushEnabled: dto.pushEnabled,
        emailNotification: dto.emailNotification,
      },
    });
  }

  async getSubscribedArtists(userId: string) {
    const subscriptions = await this.prisma.subscription.findMany({
      where: {
        fanId: userId,
        status: 'ACTIVE',
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
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return subscriptions.map((sub) => ({
      subscriptionId: sub.id,
      subscribedDays: sub.subscribedDays,
      startDate: sub.startDate,
      artist: {
        id: sub.artistProfile.id,
        stageName: sub.artistProfile.stageName,
        bio: sub.artistProfile.bio,
        profileImage: sub.artistProfile.profileImage,
        category: sub.artistProfile.category,
      },
    }));
  }

  async deleteAccount(userId: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        status: 'DELETED',
        email: `deleted_${userId}@deleted.indiefan.com`,
        nickname: '탈퇴한 사용자',
        profileImage: null,
        kakaoId: null,
        googleId: null,
        appleId: null,
      },
    });
  }
}
