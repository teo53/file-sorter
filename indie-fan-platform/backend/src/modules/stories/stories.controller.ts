import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { StoriesService } from './stories.service';
import { CreateStoryDto } from './dto/create-story.dto';
import { ReactToStoryDto } from './dto/react-to-story.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('stories')
@Controller('stories')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class StoriesController {
  constructor(private readonly storiesService: StoriesService) {}

  // ============ 팬 API ============

  @Get('feed')
  @ApiOperation({ summary: '스토리 피드 조회 (팬용)' })
  @ApiResponse({ status: 200, description: '아티스트별 스토리 그룹' })
  async getStoryFeed(@CurrentUser('id') fanUserId: string) {
    return this.storiesService.getStoryFeed(fanUserId);
  }

  @Get('artist/:artistId')
  @ApiOperation({ summary: '특정 아티스트의 스토리 조회' })
  @ApiResponse({ status: 200, description: '아티스트 스토리 목록' })
  @ApiResponse({ status: 404, description: '아티스트를 찾을 수 없음' })
  async getArtistStories(
    @CurrentUser('id') fanUserId: string,
    @Param('artistId') artistId: string,
  ) {
    return this.storiesService.getArtistStories(fanUserId, artistId);
  }

  @Post(':storyId/view')
  @ApiOperation({ summary: '스토리 조회 기록' })
  @ApiResponse({ status: 201, description: '조회 기록 완료' })
  @ApiResponse({ status: 404, description: '스토리를 찾을 수 없음' })
  async markAsViewed(
    @CurrentUser('id') fanUserId: string,
    @Param('storyId') storyId: string,
  ) {
    return this.storiesService.markAsViewed(fanUserId, storyId);
  }

  @Post(':storyId/react')
  @ApiOperation({ summary: '스토리에 리액션' })
  @ApiResponse({ status: 201, description: '리액션 완료' })
  @ApiResponse({ status: 404, description: '스토리를 찾을 수 없음' })
  async reactToStory(
    @CurrentUser('id') fanUserId: string,
    @Param('storyId') storyId: string,
    @Body() dto: ReactToStoryDto,
  ) {
    return this.storiesService.reactToStory(fanUserId, storyId, dto);
  }

  // ============ 아티스트 API ============

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '스토리 생성 (아티스트용)' })
  @ApiResponse({ status: 201, description: '스토리 업로드 성공' })
  @ApiResponse({ status: 403, description: '승인된 아티스트만 가능' })
  async createStory(
    @CurrentUser('id') artistUserId: string,
    @Body() dto: CreateStoryDto,
  ) {
    return this.storiesService.createStory(artistUserId, dto);
  }

  @Get('my-stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '내 스토리 통계 (아티스트용)' })
  @ApiResponse({ status: 200, description: '스토리 통계' })
  async getMyStoryStats(@CurrentUser('id') artistUserId: string) {
    return this.storiesService.getMyStoryStats(artistUserId);
  }

  @Delete(':storyId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ARTIST)
  @ApiOperation({ summary: '스토리 삭제 (아티스트용)' })
  @ApiResponse({ status: 200, description: '삭제 완료' })
  @ApiResponse({ status: 403, description: '삭제 권한 없음' })
  @ApiResponse({ status: 404, description: '스토리를 찾을 수 없음' })
  async deleteStory(
    @CurrentUser('id') artistUserId: string,
    @Param('storyId') storyId: string,
  ) {
    return this.storiesService.deleteStory(artistUserId, storyId);
  }
}
