import {
  Controller,
  Get,
  Post,
  Put,
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
import { ArtistsService } from './artists.service';
import { CreateArtistProfileDto } from './dto/create-artist-profile.dto';
import { UpdateArtistProfileDto } from './dto/update-artist-profile.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
import { ArtistCategory, UserRole, User } from '@prisma/client';

@ApiTags('artists')
@Controller('artists')
export class ArtistsController {
  constructor(private readonly artistsService: ArtistsService) {}

  @Post('register')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '아티스트로 등록 신청' })
  @ApiResponse({ status: 201, description: '아티스트 등록 신청 완료' })
  async registerAsArtist(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateArtistProfileDto,
  ) {
    return this.artistsService.createProfile(userId, dto);
  }

  @Get()
  @Public()
  @ApiOperation({ summary: '아티스트 목록 조회' })
  @ApiQuery({ name: 'category', enum: ArtistCategory, required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'sortBy', enum: ['popular', 'new', 'name'], required: false })
  @ApiResponse({ status: 200, description: '아티스트 목록' })
  async findAll(
    @Query('category') category?: ArtistCategory,
    @Query('search') search?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('sortBy') sortBy?: 'popular' | 'new' | 'name',
  ) {
    return this.artistsService.findAll({
      category,
      search,
      page: page || 1,
      limit: limit || 20,
      sortBy: sortBy || 'popular',
    });
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '내 아티스트 프로필 조회' })
  @ApiResponse({ status: 200, description: '아티스트 프로필' })
  async getMyProfile(@CurrentUser('id') userId: string) {
    return this.artistsService.getMyProfile(userId);
  }

  @Get('me/dashboard')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '아티스트 대시보드 통계' })
  @ApiResponse({ status: 200, description: '대시보드 통계' })
  async getDashboardStats(@CurrentUser('id') userId: string) {
    return this.artistsService.getDashboardStats(userId);
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '내 아티스트 프로필 수정' })
  @ApiResponse({ status: 200, description: '프로필 수정 완료' })
  async updateMyProfile(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateArtistProfileDto,
  ) {
    return this.artistsService.updateProfile(userId, dto);
  }

  @Get(':id')
  @Public()
  @ApiOperation({ summary: '아티스트 상세 조회' })
  @ApiResponse({ status: 200, description: '아티스트 상세 정보' })
  async findOne(
    @Param('id') id: string,
    @CurrentUser() user?: User,
  ) {
    return this.artistsService.findOne(id, user?.id);
  }

  // 관리자용 API
  @Post(':id/approve')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: '아티스트 승인 (관리자)' })
  @ApiResponse({ status: 200, description: '승인 완료' })
  async approveArtist(@Param('id') id: string) {
    return this.artistsService.approveArtist(id);
  }

  @Post(':id/reject')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: '아티스트 거절 (관리자)' })
  @ApiResponse({ status: 200, description: '거절 완료' })
  async rejectArtist(@Param('id') id: string) {
    return this.artistsService.rejectArtist(id);
  }
}
