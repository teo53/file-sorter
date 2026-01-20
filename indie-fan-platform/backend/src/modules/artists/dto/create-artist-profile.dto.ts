import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  IsInt,
  Min,
  Max,
  MaxLength,
} from 'class-validator';
import { ArtistCategory } from '@prisma/client';

export class CreateArtistProfileDto {
  @ApiProperty({ example: '아티스트명', description: '활동명' })
  @IsString()
  @IsNotEmpty({ message: '활동명을 입력해주세요.' })
  @MaxLength(50)
  stageName: string;

  @ApiPropertyOptional({ example: '홍길동', description: '실명 (비공개)' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  realName?: string;

  @ApiPropertyOptional({
    example: '안녕하세요! 아이돌을 꿈꾸는 아티스트입니다.',
    description: '자기소개',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @ApiProperty({
    enum: ArtistCategory,
    example: ArtistCategory.IDOL,
    description: '카테고리',
  })
  @IsEnum(ArtistCategory)
  category: ArtistCategory;

  @ApiPropertyOptional({
    example: 'https://example.com/profile.jpg',
    description: '프로필 이미지',
  })
  @IsOptional()
  @IsString()
  profileImage?: string;

  @ApiPropertyOptional({
    example: 'https://example.com/cover.jpg',
    description: '커버 이미지',
  })
  @IsOptional()
  @IsString()
  coverImage?: string;

  @ApiPropertyOptional({ example: 'artist_twitter', description: '트위터 핸들' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  twitterHandle?: string;

  @ApiPropertyOptional({ example: 'artist_insta', description: '인스타그램 핸들' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  instagramHandle?: string;

  @ApiPropertyOptional({
    example: 'UCxxxxxxxxx',
    description: '유튜브 채널 ID',
  })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  youtubeChannel?: string;

  @ApiPropertyOptional({ example: 'artist_tiktok', description: '틱톡 핸들' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  tiktokHandle?: string;

  @ApiPropertyOptional({
    example: 4900,
    description: '월 구독료 (원)',
    minimum: 2000,
    maximum: 10000,
  })
  @IsOptional()
  @IsInt()
  @Min(2000)
  @Max(10000)
  subscriptionPrice?: number;

  @ApiPropertyOptional({
    example: '구독해줘서 고마워요! 앞으로 잘 부탁해요~',
    description: '구독 시 자동 발송되는 환영 메시지',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  welcomeMessage?: string;

  @ApiPropertyOptional({ example: '러버스', description: '팬덤명' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  fandomName?: string;
}
