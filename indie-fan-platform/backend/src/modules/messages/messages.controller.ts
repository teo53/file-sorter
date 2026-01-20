import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { MessagesService } from './messages.service';
import { SendMessageDto } from './dto/send-message.dto';
import { SendReplyDto } from './dto/send-reply.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('messages')
@Controller('messages')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  // ============ 팬 API ============

  @Get('chat-rooms')
  @ApiOperation({ summary: '내 채팅방 목록 (팬용)' })
  @ApiResponse({ status: 200, description: '채팅방 목록' })
  async getMyChatRooms(@CurrentUser('id') fanUserId: string) {
    return this.messagesService.getMyChatRooms(fanUserId);
  }

  @Get('chat-rooms/:chatRoomId')
  @ApiOperation({ summary: '채팅방 메시지 목록 조회' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: '메시지 목록' })
  async getChatMessages(
    @CurrentUser('id') fanUserId: string,
    @Param('chatRoomId') chatRoomId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.messagesService.getChatMessages(fanUserId, chatRoomId, {
      page,
      limit,
    });
  }

  @Post('chat-rooms/:chatRoomId/reply')
  @ApiOperation({ summary: '팬이 아티스트에게 답장 보내기' })
  @ApiResponse({ status: 201, description: '답장 전송 성공' })
  async sendReply(
    @CurrentUser('id') fanUserId: string,
    @Param('chatRoomId') chatRoomId: string,
    @Body() dto: SendReplyDto,
  ) {
    return this.messagesService.sendReply(fanUserId, chatRoomId, dto);
  }

  // ============ 아티스트 API ============

  @Post('broadcast')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '전체 구독자에게 메시지 발송 (아티스트용)' })
  @ApiResponse({ status: 201, description: '메시지 발송 성공' })
  async broadcastMessage(
    @CurrentUser('id') artistUserId: string,
    @Body() dto: SendMessageDto,
  ) {
    return this.messagesService.broadcastMessage(artistUserId, dto);
  }

  @Get('broadcast/history')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '내 발송 메시지 히스토리 (아티스트용)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: '발송 히스토리' })
  async getBroadcastHistory(
    @CurrentUser('id') artistUserId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.messagesService.getBroadcastHistory(artistUserId, {
      page,
      limit,
    });
  }

  @Get('broadcast/:broadcastId/stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '발송 메시지 통계 조회 (아티스트용)' })
  @ApiResponse({ status: 200, description: '메시지 통계' })
  async getBroadcastStats(
    @CurrentUser('id') artistUserId: string,
    @Param('broadcastId') broadcastId: string,
  ) {
    return this.messagesService.getBroadcastStats(artistUserId, broadcastId);
  }

  @Get('replies')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '팬들의 답장 모아보기 (아티스트용)' })
  @ApiQuery({ name: 'broadcastId', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: '팬 답장 목록' })
  async getFanReplies(
    @CurrentUser('id') artistUserId: string,
    @Query('broadcastId') broadcastId?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.messagesService.getFanReplies(artistUserId, {
      broadcastId,
      page,
      limit,
    });
  }
}
