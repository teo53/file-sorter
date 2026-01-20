import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum, MaxLength } from 'class-validator';
import { MessageType } from '@prisma/client';

export class SendMessageDto {
  @ApiProperty({
    example: '[name]님 안녕하세요! 오늘도 좋은 하루 보내세요~',
    description: '메시지 내용 ([name]은 팬 닉네임으로 치환됨)',
  })
  @IsString()
  @IsNotEmpty({ message: '메시지 내용을 입력해주세요.' })
  @MaxLength(2000, { message: '메시지는 최대 2000자까지 가능합니다.' })
  content: string;

  @ApiPropertyOptional({
    enum: MessageType,
    example: MessageType.TEXT,
    description: '메시지 타입',
  })
  @IsOptional()
  @IsEnum(MessageType)
  type?: MessageType;
}
