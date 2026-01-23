import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  MaxLength,
  IsUrl,
} from 'class-validator';
import { StoryMediaType, StoryVisibility } from '@prisma/client';

export class CreateStoryDto {
  @ApiProperty({
    enum: StoryMediaType,
    example: 'IMAGE',
    description: '미디어 타입 (IMAGE, VIDEO)',
  })
  @IsEnum(StoryMediaType)
  mediaType: StoryMediaType;

  @ApiProperty({
    example: 'https://cdn.example.com/story/image.jpg',
    description: '미디어 URL',
  })
  @IsString()
  @IsNotEmpty()
  @IsUrl()
  mediaUrl: string;

  @ApiPropertyOptional({
    example: 'https://cdn.example.com/story/thumb.jpg',
    description: '썸네일 URL (비디오의 경우)',
  })
  @IsOptional()
  @IsString()
  @IsUrl()
  thumbnailUrl?: string;

  @ApiPropertyOptional({
    example: '오늘의 무대! 🎤',
    description: '텍스트 오버레이 (최대 100자)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  textOverlay?: string;

  @ApiPropertyOptional({
    enum: StoryVisibility,
    example: 'PUBLIC',
    description: '공개 범위 (PUBLIC: 모든 사용자, SUBSCRIBERS: 구독자만)',
    default: 'PUBLIC',
  })
  @IsOptional()
  @IsEnum(StoryVisibility)
  visibility?: StoryVisibility;
}
