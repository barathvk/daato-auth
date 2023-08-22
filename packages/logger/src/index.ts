import { LoggerModule as PinoLoggerModule } from 'nestjs-pino'
import pino from 'pino'

export const getLogger = (name: string, level: string = 'info') => {
  return pino({
    name,
    level,
    transport: {
      target: 'pino-pretty',
      options: {
        translateTime: 'hh:MM:ss',
        ignore: 'pid,hostname,context,req',
        colorize: true,
      },
    },
  })
}

export { Logger as PinoLogger } from 'nestjs-pino'
export class LoggerModule extends PinoLoggerModule {
  static create(name: string, level: string = 'info') {
    return super.forRoot({
      pinoHttp: {
        logger: getLogger(name, level),
        autoLogging: false,
      },
    })
  }
}
