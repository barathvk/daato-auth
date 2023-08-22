import { Module, Injectable } from '@nestjs/common'
import {
  KeycloakConnectModule,
  KeycloakConnectOptionsFactory,
  PolicyEnforcementMode,
  TokenValidation,
} from 'nest-keycloak-connect'

import { ConfigModule, ConfigService } from '@api/config'

export {
  AuthenticatedUser,
  Public,
  Roles,
  RoleMatchingMode,
  AuthGuard,
} from 'nest-keycloak-connect'

@Injectable()
export class AuthConfigService implements KeycloakConnectOptionsFactory {
  constructor(private readonly cfg: ConfigService) {}
  createKeycloakConnectOptions() {
    const config = {
      authServerUrl: this.cfg.config.keycloak.url,
      realm: this.cfg.config.keycloak.realm,
      sslRequired: 'external',
      clientId: this.cfg.config.keycloak.clientId,
      secret: this.cfg.config.keycloak.clientSecret,
      cookieKey: 'KEYCLOAK_JWT',
      policyEnforcement: PolicyEnforcementMode.PERMISSIVE,
      tokenValidation: TokenValidation.ONLINE,
    }
    return config
  }
}

@Module({
  imports: [ConfigModule.load()],
  providers: [AuthConfigService],
  exports: [AuthConfigService],
})
export class AuthConfigModule {}

@Module({
  imports: [
    KeycloakConnectModule.registerAsync({
      useExisting: AuthConfigService,
      imports: [AuthConfigModule],
    }),
  ],
  exports: [KeycloakConnectModule],
})
export class AuthModule {}
