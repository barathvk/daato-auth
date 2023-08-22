import serveStatic from '@fastify/static'
import { NestFactory } from '@nestjs/core'
import {
  NestFastifyApplication,
  FastifyAdapter,
} from '@nestjs/platform-fastify'
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'
import getPort from 'get-port'
import path from 'path'

import { PinoLogger } from '@packages/logger'

interface IServer<T> {
  module: new () => T
  name: string
  prefix?: string
  description?: string
  version?: string
  port?: number
}
export const startServer = async <T>({
  module,
  name,
  prefix = 'api',
  description = '',
  version = '1.0.0',
  port = 8000,
}: IServer<T>) => {
  const app = await NestFactory.create<NestFastifyApplication>(
    module,
    new FastifyAdapter(),
    {
      bufferLogs: true,
    }
  )
  app.useLogger(app.get(PinoLogger))
  app.setGlobalPrefix(prefix)
  const config = new DocumentBuilder()
    .setTitle(name)
    .setDescription(description)
    .setVersion(version)
    .build()
  app.register(serveStatic, {
    root: path.join(__dirname, '../static'),
    prefix: `/${prefix}/docs`,
    prefixAvoidTrailingSlash: true,
  })
  const document = SwaggerModule.createDocument(app, config)
  SwaggerModule.setup(`${prefix}/openapi`, app, document)
  const serverPort = await getPort({
    port: getPort.makeRange(port, port + 100),
  })
  await app.listen(serverPort)
  return { app, port: serverPort }
}
