import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsOptional, IsEmail, IsIn } from 'class-validator';

export class SocialLoginDto {
  @ApiProperty({
    enum: ['kakao', 'google', 'apple'],
    example: 'kakao',
    description: '소셜 로그인 제공자',
  })
  @IsString()
  @IsNotEmpty()
  @IsIn(['kakao', 'google', 'apple'])
  provider: 'kakao' | 'google' | 'apple';

  @ApiProperty({
    example: '1234567890',
    description: '소셜 서비스에서 제공하는 고유 ID',
  })
  @IsString()
  @IsNotEmpty()
  socialId: string;

  @ApiPropertyOptional({ example: 'user@example.com', description: '이메일' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: '닉네임', description: '닉네임' })
  @IsOptional()
  @IsString()
  nickname?: string;

  @ApiPropertyOptional({
    example: 'https://example.com/profile.jpg',
    description: '프로필 이미지 URL',
  })
  @IsOptional()
  @IsString()
  profileImage?: string;
}
