import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateFcmTokenDto {
  @ApiProperty({
    example: 'fcm_token_here',
    description: 'FCM 푸시 토큰',
  })
  @IsString()
  @IsNotEmpty({ message: 'FCM 토큰을 입력해주세요.' })
  fcmToken: string;
}
