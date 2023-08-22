import { IsDefined } from 'class-validator'
import mock from 'mock-fs'

import { loadConfigAsync } from '@/index'

class Config {
  @IsDefined()
  name: string
}
describe('index', () => {
  afterEach(() => {
    mock.restore()
  })
  it('should load empty config', async () => {
    mock({
      'config/default.yml': 'name: dummy-config',
    })
    const config = await loadConfigAsync(Config)
    expect(config.name).toEqual('dummy-config')
  })
  it('should load overloaded config', async () => {
    mock({
      'config/default.yml': 'name: dummy-config',
      'config/test.yml': 'name: dummy-config-development',
    })
    const config = await loadConfigAsync(Config)
    expect(config.name).toEqual('dummy-config-development')
  })
})
