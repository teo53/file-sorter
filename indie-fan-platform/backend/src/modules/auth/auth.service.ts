import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SocialLoginDto } from './dto/social-login.dto';
import { User, UserRole } from '@prisma/client';

export interface JwtPayload {
  sub: string;
  email: string;
  role: UserRole;
}

export interface AuthResponse {
  accessToken: string;
  user: Omit<User, 'password'>;
}

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    // Check if email exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (existingUser) {
      throw new ConflictException('이미 사용 중인 이메일입니다.');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        password: hashedPassword,
        nickname: dto.nickname,
        role: dto.role || UserRole.FAN,
      },
    });

    return this.generateAuthResponse(user);
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.validateUser(dto.email, dto.password);

    // Update last login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return this.generateAuthResponse(user);
  }

  async validateUser(email: string, password: string): Promise<User> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user || !user.password) {
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    if (user.status !== 'ACTIVE') {
      throw new UnauthorizedException('계정이 비활성화 상태입니다.');
    }

    return user;
  }

  async socialLogin(dto: SocialLoginDto): Promise<AuthResponse> {
    let user: User | null = null;

    // Find user by social ID
    switch (dto.provider) {
      case 'kakao':
        user = await this.prisma.user.findUnique({
          where: { kakaoId: dto.socialId },
        });
        break;
      case 'google':
        user = await this.prisma.user.findUnique({
          where: { googleId: dto.socialId },
        });
        break;
      case 'apple':
        user = await this.prisma.user.findUnique({
          where: { appleId: dto.socialId },
        });
        break;
      default:
        throw new BadRequestException('지원하지 않는 소셜 로그인입니다.');
    }

    // If user doesn't exist, create new one
    if (!user) {
      // Check if email exists
      if (dto.email) {
        const existingUser = await this.prisma.user.findUnique({
          where: { email: dto.email },
        });

        if (existingUser) {
          // Link social account to existing user
          const updateData: any = {};
          if (dto.provider === 'kakao') updateData.kakaoId = dto.socialId;
          if (dto.provider === 'google') updateData.googleId = dto.socialId;
          if (dto.provider === 'apple') updateData.appleId = dto.socialId;

          user = await this.prisma.user.update({
            where: { id: existingUser.id },
            data: updateData,
          });
        }
      }

      if (!user) {
        // Create new user
        const createData: any = {
          email: dto.email || `${dto.provider}_${dto.socialId}@temp.indiefan.com`,
          nickname: dto.nickname || `User_${dto.socialId.slice(0, 8)}`,
          profileImage: dto.profileImage,
          role: UserRole.FAN,
        };

        if (dto.provider === 'kakao') createData.kakaoId = dto.socialId;
        if (dto.provider === 'google') createData.googleId = dto.socialId;
        if (dto.provider === 'apple') createData.appleId = dto.socialId;

        user = await this.prisma.user.create({ data: createData });
      }
    }

    // Update last login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return this.generateAuthResponse(user);
  }

  async refreshToken(userId: string): Promise<AuthResponse> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('사용자를 찾을 수 없습니다.');
    }

    return this.generateAuthResponse(user);
  }

  async updateFcmToken(userId: string, fcmToken: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
    });

    // Also save to DeviceToken table
    await this.prisma.deviceToken.upsert({
      where: {
        userId_token: {
          userId,
          token: fcmToken,
        },
      },
      update: {
        isActive: true,
        updatedAt: new Date(),
      },
      create: {
        userId,
        token: fcmToken,
        platform: 'unknown', // Will be updated from client
      },
    });
  }

  private generateAuthResponse(user: User): AuthResponse {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const { password, ...userWithoutPassword } = user;

    return {
      accessToken: this.jwtService.sign(payload),
      user: userWithoutPassword as Omit<User, 'password'>,
    };
  }
}
