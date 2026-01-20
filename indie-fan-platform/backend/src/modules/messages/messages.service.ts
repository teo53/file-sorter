import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { SendMessageDto } from './dto/send-message.dto';
import { SendReplyDto } from './dto/send-reply.dto';
import { MessageType, MessageSender } from '@prisma/client';

const MAX_REPLY_COUNT = 3; // 메시지당 최대 답장 횟수
const MAX_REPLY_LENGTH = 100; // 최대 답장 글자 수

@Injectable()
export class MessagesService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  // 아티스트가 전체 구독자에게 메시지 발송 (브로드캐스트)
  async broadcastMessage(artistUserId: string, dto: SendMessageDto) {
    // Get artist profile
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    // Get all active subscriptions
    const subscriptions = await this.prisma.subscription.findMany({
      where: {
        artistProfileId: artist.id,
        status: 'ACTIVE',
      },
      include: {
        chatRoom: true,
        fan: true,
      },
    });

    if (subscriptions.length === 0) {
      throw new BadRequestException('구독자가 없습니다.');
    }

    // Create broadcast message record
    const broadcast = await this.prisma.broadcastMessage.create({
      data: {
        artistProfileId: artist.id,
        type: dto.type || MessageType.TEXT,
        content: dto.content,
        recipientCount: subscriptions.length,
      },
    });

    // Send message to each subscriber's chat room
    const messagePromises = subscriptions.map(async (sub) => {
      if (!sub.chatRoom) return null;

      // Personalize message with fan's nickname
      const personalizedContent = dto.content.replace(
        /\[name\]/g,
        sub.fan.nickname || '팬',
      );

      // Create message in chat room
      const message = await this.prisma.message.create({
        data: {
          chatRoomId: sub.chatRoom.id,
          senderType: MessageSender.ARTIST,
          artistProfileId: artist.id,
          type: dto.type || MessageType.TEXT,
          content: personalizedContent,
          originalContent: dto.content,
          broadcastId: broadcast.id,
        },
      });

      // Reset fan reply count for new message
      await this.prisma.chatRoom.update({
        where: { id: sub.chatRoom.id },
        data: { fanReplyCount: 0 },
      });

      // Send push notification
      if (sub.fan.pushEnabled && sub.fan.fcmToken) {
        await this.notificationsService.sendPushNotification(
          sub.fan.id,
          {
            title: artist.stageName,
            body:
              dto.type === MessageType.TEXT
                ? personalizedContent.substring(0, 50)
                : `새로운 ${dto.type === MessageType.IMAGE ? '사진' : '미디어'}이 도착했어요!`,
            data: {
              type: 'NEW_MESSAGE',
              chatRoomId: sub.chatRoom.id,
              artistId: artist.id,
            },
          },
        );
      }

      return message;
    });

    await Promise.all(messagePromises);

    // Update artist message count
    await this.prisma.artistProfile.update({
      where: { id: artist.id },
      data: {
        totalMessageCount: { increment: 1 },
      },
    });

    return {
      broadcastId: broadcast.id,
      recipientCount: subscriptions.length,
      message: `${subscriptions.length}명의 팬에게 메시지를 보냈습니다.`,
    };
  }

  // 팬이 답장 보내기
  async sendReply(fanUserId: string, chatRoomId: string, dto: SendReplyDto) {
    // Get chat room and verify access
    const chatRoom = await this.prisma.chatRoom.findUnique({
      where: { id: chatRoomId },
      include: {
        subscription: {
          include: {
            artistProfile: true,
          },
        },
        messages: {
          where: {
            senderType: MessageSender.ARTIST,
          },
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    if (!chatRoom) {
      throw new NotFoundException('채팅방을 찾을 수 없습니다.');
    }

    if (chatRoom.subscription.fanId !== fanUserId) {
      throw new ForbiddenException('이 채팅방에 접근할 권한이 없습니다.');
    }

    if (chatRoom.subscription.status !== 'ACTIVE') {
      throw new ForbiddenException('구독이 만료되어 답장을 보낼 수 없습니다.');
    }

    // Check reply limit
    if (chatRoom.fanReplyCount >= MAX_REPLY_COUNT) {
      throw new BadRequestException(
        `메시지당 최대 ${MAX_REPLY_COUNT}회까지만 답장할 수 있습니다.`,
      );
    }

    // Check message length
    if (dto.content.length > MAX_REPLY_LENGTH) {
      throw new BadRequestException(
        `답장은 최대 ${MAX_REPLY_LENGTH}자까지 가능합니다.`,
      );
    }

    // Get the last artist message to reply to
    const lastArtistMessage = chatRoom.messages[0];

    // Create reply message
    const reply = await this.prisma.message.create({
      data: {
        chatRoomId,
        senderType: MessageSender.FAN,
        fanUserId,
        type: MessageType.TEXT,
        content: dto.content,
        replyToId: lastArtistMessage?.id,
      },
    });

    // Increment reply count
    await this.prisma.chatRoom.update({
      where: { id: chatRoomId },
      data: {
        fanReplyCount: { increment: 1 },
      },
    });

    // Update broadcast reply count if applicable
    if (lastArtistMessage?.broadcastId) {
      await this.prisma.broadcastMessage.update({
        where: { id: lastArtistMessage.broadcastId },
        data: {
          replyCount: { increment: 1 },
        },
      });
    }

    return {
      messageId: reply.id,
      remainingReplies: MAX_REPLY_COUNT - chatRoom.fanReplyCount - 1,
    };
  }

  // 채팅방 메시지 목록 조회 (팬용)
  async getChatMessages(
    fanUserId: string,
    chatRoomId: string,
    options: { page?: number; limit?: number },
  ) {
    const { page = 1, limit = 50 } = options;

    // Verify access
    const chatRoom = await this.prisma.chatRoom.findUnique({
      where: { id: chatRoomId },
      include: {
        subscription: true,
      },
    });

    if (!chatRoom || chatRoom.subscription.fanId !== fanUserId) {
      throw new ForbiddenException('이 채팅방에 접근할 권한이 없습니다.');
    }

    const [messages, total] = await Promise.all([
      this.prisma.message.findMany({
        where: { chatRoomId },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
        include: {
          artistProfile: {
            select: {
              id: true,
              stageName: true,
              profileImage: true,
            },
          },
        },
      }),
      this.prisma.message.count({ where: { chatRoomId } }),
    ]);

    // Mark messages as read
    await this.prisma.chatRoom.update({
      where: { id: chatRoomId },
      data: { fanLastReadAt: new Date() },
    });

    // Mark unread artist messages as read
    await this.prisma.message.updateMany({
      where: {
        chatRoomId,
        senderType: MessageSender.ARTIST,
        isRead: false,
      },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return {
      data: messages.reverse().map((msg) => ({
        id: msg.id,
        senderType: msg.senderType,
        type: msg.type,
        content: msg.content,
        createdAt: msg.createdAt,
        isRead: msg.isRead,
        artist: msg.artistProfile,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
      remainingReplies: MAX_REPLY_COUNT - chatRoom.fanReplyCount,
    };
  }

  // 아티스트가 팬들의 답장 모아보기
  async getFanReplies(
    artistUserId: string,
    options: { broadcastId?: string; page?: number; limit?: number },
  ) {
    const { broadcastId, page = 1, limit = 50 } = options;

    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const where: any = {
      senderType: MessageSender.FAN,
      chatRoom: {
        subscription: {
          artistProfileId: artist.id,
        },
      },
    };

    if (broadcastId) {
      where.replyTo = {
        broadcastId,
      };
    }

    const [replies, total] = await Promise.all([
      this.prisma.message.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
        include: {
          fanUser: {
            select: {
              id: true,
              nickname: true,
              profileImage: true,
            },
          },
          replyTo: {
            select: {
              id: true,
              content: true,
              createdAt: true,
            },
          },
        },
      }),
      this.prisma.message.count({ where }),
    ]);

    return {
      data: replies.map((reply) => ({
        id: reply.id,
        content: reply.content,
        createdAt: reply.createdAt,
        fan: reply.fanUser,
        replyTo: reply.replyTo,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // 내 채팅방 목록 (팬용)
  async getMyChatRooms(fanUserId: string) {
    const chatRooms = await this.prisma.chatRoom.findMany({
      where: {
        subscription: {
          fanId: fanUserId,
          status: 'ACTIVE',
        },
      },
      include: {
        subscription: {
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
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
      orderBy: {
        updatedAt: 'desc',
      },
    });

    // Count unread messages for each chat room
    const unreadCounts = await Promise.all(
      chatRooms.map(async (room) => {
        const count = await this.prisma.message.count({
          where: {
            chatRoomId: room.id,
            senderType: MessageSender.ARTIST,
            isRead: false,
          },
        });
        return { roomId: room.id, count };
      }),
    );

    const unreadMap = new Map(
      unreadCounts.map((u) => [u.roomId, u.count]),
    );

    return chatRooms.map((room) => ({
      id: room.id,
      artist: room.subscription.artistProfile,
      subscribedDays: room.subscription.subscribedDays,
      lastMessage: room.messages[0]
        ? {
            content:
              room.messages[0].type === 'TEXT'
                ? room.messages[0].content.substring(0, 50)
                : `[${room.messages[0].type}]`,
            createdAt: room.messages[0].createdAt,
            senderType: room.messages[0].senderType,
          }
        : null,
      unreadCount: unreadMap.get(room.id) || 0,
    }));
  }

  // 브로드캐스트 통계 조회 (아티스트용)
  async getBroadcastStats(artistUserId: string, broadcastId: string) {
    const artist = await this.prisma.artistProfile.findUnique({
      where: { userId: artistUserId },
    });

    if (!artist) {
      throw new NotFoundException('아티스트 프로필을 찾을 수 없습니다.');
    }

    const broadcast = await this.prisma.broadcastMessage.findFirst({
      where: {
        id: broadcastId,
        artistProfileId: artist.id,
      },
    });

    if (!broadcast) {
      throw new NotFoundException('메시지를 찾을 수 없습니다.');
    }

    // Get read count
    const readCount = await this.prisma.message.count({
      where: {
        broadcastId,
        isRead: true,
      },
    });

    return {
      id: broadcast.id,
      content: broadcast.content,
      type: broadcast.type,
      createdAt: broadcast.createdAt,
      recipientCount: broadcast.recipientCount,
      readCount,
      replyCount: broadcast.replyCount,
      readRate:
        broadcast.recipientCount > 0
          ? Math.round((readCount / broadcast.recipientCount) * 100)
          : 0,
    };
  }

  // 아티스트의 발송 메시지 히스토리
  async getBroadcastHistory(
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

    const [broadcasts, total] = await Promise.all([
      this.prisma.broadcastMessage.findMany({
        where: { artistProfileId: artist.id },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.broadcastMessage.count({
        where: { artistProfileId: artist.id },
      }),
    ]);

    return {
      data: broadcasts.map((b) => ({
        id: b.id,
        content:
          b.type === 'TEXT' ? b.content.substring(0, 100) : `[${b.type}]`,
        type: b.type,
        createdAt: b.createdAt,
        recipientCount: b.recipientCount,
        replyCount: b.replyCount,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
