import { PartialType } from '@nestjs/swagger';
import { CreateArtistProfileDto } from './create-artist-profile.dto';

export class UpdateArtistProfileDto extends PartialType(CreateArtistProfileDto) {}
