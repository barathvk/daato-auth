import { Module } from '@nestjs/common'
import { APP_GUARD } from '@nestjs/core'
import { config as dotenvConfig } from 'dotenv'
import findConfig from 'find-config'

import { LoggerModule, getLogger } from '@packages/logger'
import { startServer } from '@packages/server'

import { AuthGuard, AuthModule } from '@api/auth'
import { ConfigModule } from '@api/config'
import { UsersModule } from '@api/users'

const serviceName = 'Daato Core'
const loggerName = serviceName.replace(' ', '/').toLowerCase()

@Module({
  imports: [
    ConfigModule.load(),
    AuthModule,
    LoggerModule.create(loggerName),
    UsersModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
  ],
})
export class AppModule {}

const bootstrap = async () => {
  const logger = getLogger(loggerName)
  dotenvConfig({ path: findConfig('.env') as string })
  logger.info(
    `🚀 starting ${serviceName.toLowerCase()} in the ${
      process.env.NODE_ENV
    } environment`
  )
  const { port } = await startServer({
    name: 'Daato API',
    module: AppModule,
  })
  logger.info(`🚀 started ${serviceName.toLowerCase()} on port ${port}`)
}

if (require.main === module) {
  bootstrap()
}
