import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

export class SendReplyDto {
  @ApiProperty({
    example: '오늘도 응원합니다!',
    description: '답장 내용 (최대 100자)',
  })
  @IsString()
  @IsNotEmpty({ message: '답장 내용을 입력해주세요.' })
  @MaxLength(100, { message: '답장은 최대 100자까지 가능합니다.' })
  content: string;
}
