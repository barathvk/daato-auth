import { DynamicModule, Inject, Injectable, Module } from '@nestjs/common'
import { Type } from 'class-transformer'
import { IsDefined, ValidateNested } from 'class-validator'
import path from 'path'

import { _loadConfig } from '@packages/config'

class Keycloak {
  @IsDefined()
  url: string

  @IsDefined()
  realm: string
}

class Database {
  @IsDefined()
  url: string
}

export class Config {
  @IsDefined()
  @ValidateNested()
  @Type(() => Database)
  database: Database

  @IsDefined()
  @ValidateNested()
  @Type(() => Keycloak)
  keycloak: Keycloak
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
