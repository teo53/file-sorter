import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

export class RespondSeisanDto {
  @ApiProperty({
    example: '정말 고마워요! ❤️ 다음 앨범 열심히 준비하고 있으니까 조금만 기다려주세요.',
    description: '응답 메시지 (글자 수 제한은 티어별로 다름)',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(600) // 최대 티어 기준
  responseText: string;

  @ApiPropertyOptional({
    description: '음성 메시지 URL (음성 옵션 선택 시)',
  })
  @IsOptional()
  @IsString()
  responseVoiceUrl?: string;
}
