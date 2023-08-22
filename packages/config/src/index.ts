import 'reflect-metadata'

import { plainToClass } from 'class-transformer'
import { validateSync, ValidationError } from 'class-validator'
import merge from 'deepmerge'
import { config as dotenvConfig } from 'dotenv'
import findConfig from 'find-config'
import flat from 'flat'
import fs from 'fs'
import yaml from 'js-yaml'
import memoize from 'memoizee'
import path from 'path'
import sp from 'synchronized-promise'

import { defaultPlugins, IBasePlugin } from './plugins'

const getMessages = (messages: string[], error: ValidationError) => {
  if (error.constraints) {
    Object.values(error.constraints).forEach((msg) => messages.push(msg))
  }
  if (error.children) {
    error.children.forEach((child) => getMessages(messages, child))
  }
}
export const readAndMergeConfigFiles = (dir: string) => {
  const defaultConfig =
    yaml.load(fs.readFileSync(`${dir}/default.yml`, 'utf8')) || {}
  const exists = fs.existsSync(`${dir}/${process.env.NODE_ENV}.yml`)
  let overrideConfig: any = {}
  if (exists) {
    overrideConfig = yaml.load(
      fs.readFileSync(`${dir}/${process.env.NODE_ENV}.yml`, 'utf8')
    )
  }
  const overwriteMerge = (destinationArray: any[], sourceArray: any[]) =>
    sourceArray
  return merge(defaultConfig, overrideConfig, {
    arrayMerge: overwriteMerge,
  })
}

export const _loadConfig = async <T extends object>(
  schema: new () => T,
  dir: string = path.resolve(process.cwd(), 'config'),
  plugins: IBasePlugin[] = []
) => {
  plugins.push(...defaultPlugins)
  dotenvConfig({ path: findConfig('.env') as string })
  await Promise.all(
    plugins
      .map((plugin) => (plugin.init ? plugin.init() : undefined))
      .filter((initialize) => initialize)
  )
  const merged = readAndMergeConfigFiles(dir)
  const flattened: any = flat(merged)
  const errors: ValidationError[] = []
  const keyRegex = /\${(.*?):(.*?)}/g
  for (const flKey of Object.keys(flattened)) {
    if (typeof flattened[flKey] === 'string') {
      const key = flattened[flKey] as string
      const matches = key.matchAll(keyRegex)
      for (const match of matches || []) {
        const protocol = match[1]
        const plugin = plugins.find((pl) => pl.protocol === protocol)
        if (!plugin) {
          const error = new ValidationError()
          error.constraints = {
            plugins: `Failed to find plugin for protocol ${protocol}: ${match}`,
          }
          errors.push(error)
        } else {
          const substitution = match[2]
          const value = await plugin.getValue(substitution)
          if (value) {
            flattened[flKey] = (flattened[flKey] as string).replace(
              match[0],
              value.toString()
            )
          } else {
            const error = new ValidationError()
            error.constraints = {
              plugins: `Failed to find value ${protocol}: ${match}`,
            }
            errors.push(error)
          }
        }
      }
    }
  }
  const unflattened = flat.unflatten(flattened)

  const parsed = plainToClass(schema, unflattened as T)
  const validationErrors = validateSync(parsed, {
    forbidUnknownValues: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  })
  errors.push(...validationErrors)
  if (errors.length > 0) {
    const messages = []
    errors.forEach((error) => getMessages(messages, error))
    for (const message of messages) {
      console.error(`\x1b[31m* ${message}\x1b[0m`)
    }
    console.error('\x1b[31m[FATAL] failed to validate config\x1b[0m')
    process.exit(1)
  }
  return parsed
}

export const loadConfigAsync =
  process.env.NODE_ENV !== 'test'
    ? memoize(_loadConfig, { promise: true })
    : _loadConfig
export const loadConfig = sp(loadConfigAsync) as any
