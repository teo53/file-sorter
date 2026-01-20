import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class SubscribeDto {
  @ApiProperty({ example: 'artist-uuid', description: '아티스트 프로필 ID' })
  @IsString()
  @IsNotEmpty({ message: '아티스트 ID를 입력해주세요.' })
  artistId: string;

  @ApiPropertyOptional({
    example: 'stripe',
    description: '결제 수단 (stripe, iap_ios, iap_android)',
  })
  @IsOptional()
  @IsString()
  paymentMethod?: string;

  @ApiPropertyOptional({
    example: 'pi_xxxx',
    description: 'Stripe Payment Intent ID',
  })
  @IsOptional()
  @IsString()
  stripePaymentIntentId?: string;

  @ApiPropertyOptional({
    example: 'receipt_data',
    description: 'IAP 영수증 데이터',
  })
  @IsOptional()
  @IsString()
  iapReceipt?: string;
}
