import { Module } from '@nestjs/common';
import { SeisanController } from './seisan.controller';
import { SeisanService } from './seisan.service';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  controllers: [SeisanController],
  providers: [SeisanService],
  exports: [SeisanService],
})
export class SeisanModule {}
