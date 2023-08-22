import { Controller, Get, Module } from '@nestjs/common'
import { ApiOkResponse, ApiOperation, ApiSecurity } from '@nestjs/swagger'

import { AuthModule, AuthenticatedUser } from '@api/auth'

@Controller('users')
class UsersController {
  @ApiOperation({ summary: 'List users' })
  @ApiSecurity('bearer')
  @ApiOkResponse({ description: 'List of users' })
  @Get()
  async list(@AuthenticatedUser() user: any) {
    return {
      message: `hello ${user.preferred_username}!`,
    }
  }
}

@Module({
  imports: [AuthModule],
  controllers: [UsersController],
})
export class UsersModule {}
