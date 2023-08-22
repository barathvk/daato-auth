import { kubePlugin } from './/kube'
import { envPlugin } from './env'

export type Primitive = string | boolean | number | undefined
export interface IBasePlugin {
  protocol: string
  getValue: (key: string) => Promise<Primitive>
  init?: () => Promise<void>
}
export const defaultPlugins = [envPlugin, kubePlugin]
