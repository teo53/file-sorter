import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

export class ReactToStoryDto {
  @ApiProperty({
    example: '❤️',
    description: '이모지 리액션',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(4) // 이모지 최대 길이 (복합 이모지 고려)
  emoji: string;
}
