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
import { SeisanService } from './seisan.service';
import { CreateSeisanRequestDto } from './dto/create-seisan-request.dto';
import { RespondSeisanDto } from './dto/respond-seisan.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole, SeisanStatus } from '@prisma/client';

@ApiTags('seisan')
@Controller('seisan')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SeisanController {
  constructor(private readonly seisanService: SeisanService) {}

  // ============ 팬 API ============

  @Post('request')
  @ApiOperation({ summary: '정산 요청 생성 (팬용)' })
  @ApiResponse({ status: 201, description: '정산 요청 성공' })
  @ApiResponse({ status: 400, description: '잘못된 요청' })
  @ApiResponse({ status: 404, description: '아티스트를 찾을 수 없음' })
  async createRequest(
    @CurrentUser('id') fanUserId: string,
    @Body() dto: CreateSeisanRequestDto,
  ) {
    return this.seisanService.createRequest(fanUserId, dto);
  }

  @Get('my-requests')
  @ApiOperation({ summary: '내 정산 요청 목록 (팬용)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: SeisanStatus,
    description: '상태 필터',
  })
  @ApiResponse({ status: 200, description: '정산 목록' })
  async getMyRequests(
    @CurrentUser('id') fanUserId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: SeisanStatus,
  ) {
    return this.seisanService.getMyRequests(fanUserId, { page, limit, status });
  }

  @Get(':requestId')
  @ApiOperation({ summary: '정산 상세 조회 (팬/아티스트 공용)' })
  @ApiResponse({ status: 200, description: '정산 상세 정보' })
  @ApiResponse({ status: 403, description: '접근 권한 없음' })
  @ApiResponse({ status: 404, description: '정산을 찾을 수 없음' })
  async getRequestDetail(
    @CurrentUser('id') userId: string,
    @Param('requestId') requestId: string,
  ) {
    return this.seisanService.getRequestDetail(userId, requestId);
  }

  // ============ 아티스트 API ============

  @Get('queue')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '정산 대기 큐 조회 (아티스트용)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: '대기 큐 목록' })
  async getPendingQueue(
    @CurrentUser('id') artistUserId: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.seisanService.getPendingQueue(artistUserId, { page, limit });
  }

  @Post(':requestId/respond')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '정산 응답 작성 (아티스트용)' })
  @ApiResponse({ status: 201, description: '응답 완료' })
  @ApiResponse({ status: 400, description: '잘못된 요청 또는 글자수 초과' })
  @ApiResponse({ status: 403, description: '응답 권한 없음' })
  @ApiResponse({ status: 404, description: '정산을 찾을 수 없음' })
  async respondToRequest(
    @CurrentUser('id') artistUserId: string,
    @Param('requestId') requestId: string,
    @Body() dto: RespondSeisanDto,
  ) {
    return this.seisanService.respondToRequest(artistUserId, requestId, dto);
  }

  @Get('stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '정산 통계 조회 (아티스트용)' })
  @ApiResponse({ status: 200, description: '정산 통계' })
  async getSeisanStats(@CurrentUser('id') artistUserId: string) {
    return this.seisanService.getSeisanStats(artistUserId);
  }
}
