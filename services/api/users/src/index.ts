import { Controller, Get, Module } from '@nestjs/common'
import { ApiOkResponse, ApiOperation } from '@nestjs/swagger'

import { Config, ConfigModule, ConfigService } from '@api/config'

@Controller('users')
class UsersController {
  constructor(private readonly cfg: ConfigService) {}
  @ApiOperation({ summary: 'List users' })
  @ApiOkResponse({ description: 'List of users', type: Config })
  @Get()
  async list() {
    return this.cfg.config
  }
}

@Module({
  imports: [ConfigModule.load()],
  controllers: [UsersController],
})
export class UsersModule {}
