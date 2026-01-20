import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { SubscriptionsService } from './subscriptions.service';
import { SubscribeDto } from './dto/subscribe.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('subscriptions')
@Controller('subscriptions')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Post()
  @ApiOperation({ summary: '아티스트 구독하기' })
  @ApiResponse({ status: 201, description: '구독 성공' })
  async subscribe(
    @CurrentUser('id') fanId: string,
    @Body() dto: SubscribeDto,
  ) {
    return this.subscriptionsService.subscribe(fanId, dto);
  }

  @Get()
  @ApiOperation({ summary: '내 구독 목록 조회' })
  @ApiResponse({ status: 200, description: '구독 목록' })
  async findMySubscriptions(@CurrentUser('id') fanId: string) {
    return this.subscriptionsService.findMySubscriptions(fanId);
  }

  @Get('artist/subscribers')
  @ApiOperation({ summary: '내 구독자 목록 조회 (아티스트용)' })
  @ApiResponse({ status: 200, description: '구독자 목록' })
  async getMySubscribers(@CurrentUser('id') artistUserId: string) {
    return this.subscriptionsService.getSubscribers(artistUserId);
  }

  @Get(':id')
  @ApiOperation({ summary: '구독 상세 조회' })
  @ApiResponse({ status: 200, description: '구독 상세' })
  async findOne(
    @CurrentUser('id') fanId: string,
    @Param('id') subscriptionId: string,
  ) {
    return this.subscriptionsService.findOne(fanId, subscriptionId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '구독 취소' })
  @ApiResponse({ status: 200, description: '구독 취소 완료' })
  async cancel(
    @CurrentUser('id') fanId: string,
    @Param('id') subscriptionId: string,
  ) {
    return this.subscriptionsService.cancel(fanId, subscriptionId);
  }
}
