import { Module } from '@nestjs/common'

import { LoggerModule, getLogger } from '@packages/logger'
import { startServer } from '@packages/server'

import { UsersModule } from '@api/users'

const serviceName = 'Daato Core'
const loggerName = serviceName.replace(' ', '/').toLowerCase()

@Module({
  imports: [LoggerModule.create(loggerName), UsersModule],
})
export class AppModule {}

const bootstrap = async () => {
  const { port } = await startServer({
    name: 'Daato API',
    module: AppModule,
  })
  const logger = getLogger(loggerName)
  logger.info(`🚀 started ${serviceName.toLowerCase()} on port ${port}`)
}

if (require.main === module) {
  bootstrap()
}
