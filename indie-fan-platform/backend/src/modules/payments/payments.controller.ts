import {
  Controller,
  Get,
  Post,
  Param,
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
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('payments')
@Controller('payments')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('intent/:artistId')
  @ApiOperation({ summary: '결제 인텐트 생성 (Stripe)' })
  @ApiResponse({ status: 201, description: '결제 인텐트 생성 성공' })
  async createPaymentIntent(
    @CurrentUser('id') userId: string,
    @Param('artistId') artistId: string,
  ) {
    return this.paymentsService.createPaymentIntent(userId, artistId);
  }

  @Get('history')
  @ApiOperation({ summary: '내 결제 내역 조회' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: '결제 내역' })
  async getMyPayments(
    @CurrentUser('id') userId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.paymentsService.getMyPayments(userId, { page, limit });
  }

  // 아티스트용 API
  @Get('revenue')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '아티스트 수익 조회' })
  @ApiResponse({ status: 200, description: '수익 정보' })
  async getArtistRevenue(@CurrentUser('id') artistUserId: string) {
    return this.paymentsService.getArtistRevenue(artistUserId);
  }

  @Get('settlements')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '정산 내역 조회' })
  @ApiResponse({ status: 200, description: '정산 내역' })
  async getSettlements(@CurrentUser('id') artistUserId: string) {
    return this.paymentsService.getSettlements(artistUserId);
  }

  @Post('settlements/request')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '정산 요청' })
  @ApiResponse({ status: 201, description: '정산 요청 완료' })
  async requestSettlement(@CurrentUser('id') artistUserId: string) {
    return this.paymentsService.requestSettlement(artistUserId);
  }
}
