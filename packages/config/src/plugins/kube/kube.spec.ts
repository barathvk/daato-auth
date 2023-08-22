import { IsDefined } from 'class-validator'
import mock from 'mock-fs'

import { loadConfigAsync } from '../../index'

class Config {
  @IsDefined()
  domain: string
}
describe('env plugin', () => {
  afterEach(() => {
    mock.restore()
  })
  it('should substitute single environment variable', async () => {
    mock({
      'config/default.yml': 'domain: ${kube:domain/domain}',
    })
    const config = await loadConfigAsync(Config)
    expect(config.domain).toEqual('daato.localhost')
  })
})
