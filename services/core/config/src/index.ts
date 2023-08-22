import { DynamicModule, Inject, Injectable, Module } from '@nestjs/common'
import { IsDefined } from 'class-validator'
import path from 'path'

import { _loadConfig } from '@packages/config'

export class Config {
  @IsDefined()
  dbUrl: string
}

@Injectable()
export class ConfigService {
  readonly config: Config
  constructor(@Inject('CONFIG') _config: Config) {
    this.config = _config
  }
}

@Module({})
export class ConfigModule {
  static load(): DynamicModule {
    return {
      module: ConfigModule,
      providers: [
        {
          provide: 'CONFIG',
          useFactory: async () => {
            return _loadConfig(Config, path.resolve(__dirname, '../config'))
          },
        },
        ConfigService,
      ],
      exports: [ConfigService],
    }
  }
}
