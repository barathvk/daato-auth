import { IsDefined, IsOptional } from 'class-validator'
import mock from 'mock-fs'

import { loadConfigAsync } from '../../index'

class Config {
  @IsDefined()
  name: string

  @IsOptional()
  suffix: string
}
describe('env plugin', () => {
  afterEach(() => {
    mock.restore()
  })
  it('should substitute single environment variable', async () => {
    mock({
      'config/default.yml': 'name: ${env:NAME}',
      '.env': 'NAME=dummy-name',
    })
    const config = await loadConfigAsync(Config)
    expect(config.name).toEqual('dummy-name')
  })
  it('should substitute concatenated environment variables', async () => {
    mock({
      'config/default.yml': 'name: ${env:NAME}-${env:SUFFIX}',
      '.env': 'NAME=dummy-name\nSUFFIX=suffix',
    })
    const config = await loadConfigAsync(Config)
    expect(config.name).toEqual('dummy-name-suffix')
  })
  it('should substitute multiple environment variables', async () => {
    mock({
      'config/default.yml': 'name: ${env:NAME}\nsuffix: ${env:SUFFIX}',
      '.env': 'NAME=dummy-name\nSUFFIX=suffix',
    })
    const config = await loadConfigAsync(Config)
    expect(config.name).toEqual('dummy-name')
    expect(config.suffix).toEqual('suffix')
  })
})
