import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationType } from '@prisma/client';
// import * as admin from 'firebase-admin';

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, any>;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  // private firebaseApp: admin.app.App | null = null;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    // Initialize Firebase Admin SDK
    // const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    // if (projectId) {
    //   this.firebaseApp = admin.initializeApp({
    //     credential: admin.credential.cert({
    //       projectId,
    //       clientEmail: this.configService.get<string>('FIREBASE_CLIENT_EMAIL'),
    //       privateKey: this.configService.get<string>('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
    //     }),
    //   });
    // }
  }

  // 푸시 알림 전송
  async sendPushNotification(userId: string, payload: PushPayload) {
    try {
      // Get user's FCM token
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { fcmToken: true, pushEnabled: true },
      });

      if (!user?.pushEnabled || !user?.fcmToken) {
        return { success: false, reason: 'Push disabled or no token' };
      }

      // Save notification to database
      await this.createNotification(userId, {
        type: (payload.data?.type as NotificationType) || NotificationType.SYSTEM,
        title: payload.title,
        body: payload.body,
        data: payload.data,
      });

      // Send FCM push notification
      // if (this.firebaseApp && user.fcmToken) {
      //   const message = {
      //     notification: {
      //       title: payload.title,
      //       body: payload.body,
      //     },
      //     data: payload.data ?
      //       Object.fromEntries(
      //         Object.entries(payload.data).map(([k, v]) => [k, String(v)])
      //       ) : {},
      //     token: user.fcmToken,
      //   };
      //
      //   await admin.messaging().send(message);
      // }

      this.logger.log(`Push notification sent to user ${userId}: ${payload.title}`);
      return { success: true };
    } catch (error) {
      this.logger.error(`Failed to send push notification: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  // 다수 사용자에게 푸시 전송
  async sendPushToMultiple(userIds: string[], payload: PushPayload) {
    const results = await Promise.allSettled(
      userIds.map((userId) => this.sendPushNotification(userId, payload)),
    );

    const succeeded = results.filter((r) => r.status === 'fulfilled').length;
    const failed = results.filter((r) => r.status === 'rejected').length;

    return { succeeded, failed, total: userIds.length };
  }

  // 알림 생성 (DB 저장)
  async createNotification(
    userId: string,
    data: {
      type: NotificationType;
      title: string;
      body: string;
      data?: Record<string, any>;
    },
  ) {
    return this.prisma.notification.create({
      data: {
        userId,
        type: data.type,
        title: data.title,
        body: data.body,
        data: data.data,
      },
    });
  }

  // 내 알림 목록 조회
  async getMyNotifications(
    userId: string,
    options: { page?: number; limit?: number },
  ) {
    const { page = 1, limit = 20 } = options;

    const [notifications, total, unreadCount] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.notification.count({ where: { userId } }),
      this.prisma.notification.count({
        where: { userId, isRead: false },
      }),
    ]);

    return {
      data: notifications,
      unreadCount,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // 알림 읽음 처리
  async markAsRead(userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });

    if (!notification) {
      return { success: false };
    }

    await this.prisma.notification.update({
      where: { id: notificationId },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return { success: true };
  }

  // 모든 알림 읽음 처리
  async markAllAsRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return { success: true };
  }

  // 읽지 않은 알림 수
  async getUnreadCount(userId: string) {
    const count = await this.prisma.notification.count({
      where: { userId, isRead: false },
    });

    return { unreadCount: count };
  }

  // 구독 기념일 알림 전송 (크론잡용)
  async sendAnniversaryNotifications() {
    // Find subscriptions with special anniversary days (100, 200, 365, etc.)
    const milestones = [100, 200, 300, 365, 500, 730, 1000];

    for (const milestone of milestones) {
      const subscriptions = await this.prisma.subscription.findMany({
        where: {
          status: 'ACTIVE',
          subscribedDays: milestone,
        },
        include: {
          fan: true,
          artistProfile: true,
        },
      });

      for (const sub of subscriptions) {
        await this.sendPushNotification(sub.fanId, {
          title: `${sub.artistProfile.stageName}님과 ${milestone}일째!`,
          body: `${sub.fan.nickname}님, ${sub.artistProfile.stageName}님을 만난 지 ${milestone}일이 되었어요!`,
          data: {
            type: NotificationType.ANNIVERSARY,
            artistId: sub.artistProfile.id,
            milestone,
          },
        });
      }
    }
  }

  // 구독 만료 예정 알림 (크론잡용)
  async sendExpiringNotifications() {
    const threeDaysLater = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000);
    const now = new Date();

    const expiringSubscriptions = await this.prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        autoRenewal: false,
        renewalDate: {
          gte: now,
          lte: threeDaysLater,
        },
      },
      include: {
        fan: true,
        artistProfile: true,
      },
    });

    for (const sub of expiringSubscriptions) {
      const daysLeft = Math.ceil(
        (sub.renewalDate!.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
      );

      await this.sendPushNotification(sub.fanId, {
        title: '구독 만료 예정',
        body: `${sub.artistProfile.stageName}님 구독이 ${daysLeft}일 후 만료됩니다. 갱신해주세요!`,
        data: {
          type: NotificationType.SUBSCRIPTION_EXPIRING,
          subscriptionId: sub.id,
          artistId: sub.artistProfile.id,
        },
      });
    }
  }
}
