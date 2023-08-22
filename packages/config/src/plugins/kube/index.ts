import * as k8s from '@kubernetes/client-node'
import atob from 'atob'
import * as process from 'process'

import { IBasePlugin } from '..'

const kc = new k8s.KubeConfig()
if (process.env.KUBERNETES_SERVICE_HOST) {
  console.log('running inside kubernetes')
  kc.loadFromCluster()
} else {
  kc.loadFromDefault()
}

export const kubePlugin: IBasePlugin = {
  protocol: 'kube',
  getValue: async (key: string) => {
    try {
      const api = kc.makeApiClient(k8s.CoreV1Api)
      const split = key.split('/')
      const secretKey = split[0]
      let secretName = secretKey
      let namespace: string
      if (secretKey.includes('.')) {
        const secretSplit = secretKey.split('.')
        secretName = secretSplit[0]
        namespace = secretSplit[1]
      } else {
        namespace = process.env.ORGANIZATION || 'default'
      }
      const dataKey = split[1]
      const secret = await api.readNamespacedSecret(secretName, namespace)
      if (secret?.body?.data) {
        return atob(secret.body.data[dataKey])
      }
      return undefined
    } catch (error) {
      console.error(
        `[${key}] (context: ${kc.currentContext}) ${(error as Error).message}`
      )
      throw error
    }
  },
}
