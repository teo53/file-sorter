import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsInt,
  IsBoolean,
  IsOptional,
  Min,
  MaxLength,
  IsIn,
} from 'class-validator';

export class CreateSeisanRequestDto {
  @ApiProperty({
    example: 'artist_uuid',
    description: '아티스트 프로필 ID',
  })
  @IsString()
  @IsNotEmpty()
  artistProfileId: string;

  @ApiProperty({
    example: 5000,
    description: '정산 금액 (3000, 5000, 10000, 20000원)',
  })
  @IsInt()
  @IsIn([3000, 5000, 10000, 20000], {
    message: '유효한 금액을 선택해주세요 (3000, 5000, 10000, 20000원)',
  })
  offerAmount: number;

  @ApiProperty({
    example: '유나님 항상 응원해요! 다음 앨범 기대하고 있어요 💕',
    description: '요청 메시지 (최대 500자)',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  requestMessage: string;

  @ApiPropertyOptional({
    example: false,
    description: '음성 메시지 옵션 (+10,000원)',
  })
  @IsOptional()
  @IsBoolean()
  voiceOption?: boolean;

  @ApiPropertyOptional({
    description: '첨부 이미지 URL (체키 등)',
  })
  @IsOptional()
  @IsString()
  chekiImageUrl?: string;
}
