import { Injectable, OnModuleInit, Module, Logger } from '@nestjs/common'
import { ConnectionStringParser } from 'connection-string-parser'

import { ConfigModule, ConfigService } from '@core/config'

import { PrismaClient } from './model/client'

export { PrismaModel as ent } from './model/entities'

@Injectable()
export class ModelService extends PrismaClient implements OnModuleInit {
  private readonly logger = new Logger()
  constructor(private cfg: ConfigService) {
    super({
      datasources: {
        db: {
          url: cfg.config.dbUrl,
        },
      },
    })
  }
  async onModuleInit() {
    await this.$connect()
    const { password } = new ConnectionStringParser({
      scheme: 'postgres',
      hosts: [],
    }).parse(this.cfg.config.dbUrl)
    this.logger.log(
      `🔗 connected to database at ${this.cfg.config.dbUrl.replace(
        password!,
        '****'
      )}`
    )
  }
}

@Module({
  imports: [ConfigModule.load()],
  providers: [ModelService],
  exports: [ModelService],
})
export class ModelModule {}
