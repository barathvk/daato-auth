data "kubernetes_secret" "domain" {
  metadata {
    name      = "domain"
    namespace = "default"
  }
}
data "kubernetes_secret" "cosmosdb" {
  metadata {
    name      = "cosmosdb"
    namespace = "default"
  }
}
data "kubernetes_secret" "mongodb" {
  depends_on = [module.mongodb]
  metadata {
    name      = "mongodb"
    namespace = var.identifier
  }
}
locals {
  domain           = data.kubernetes_secret.domain.data.domain
  mongodb_password = data.kubernetes_secret.mongodb.data["mongodb-root-password"]
  api_env = {
    DB_URL                                            = "mongodb://root:${local.mongodb_password}@mongodb.${var.identifier}:27017?authSource=admin"
    JWT_AUDIENCE                                      = module.auth0.resource_servers.api
    ENV_NAME                                          = var.identifier
    AUTH0_DOMAIN                                      = module.auth0.domain
    AUTH0_MANAGEMENT_CLIENT_ID                        = module.auth0.clients["management"]["client_id"]
    AUTH0_MANAGEMENT_CLIENT_SECRET                    = module.auth0.clients["management"]["client_secret"]
    AUTH0_ORGANIZATION_ID                             = module.auth0.organization_id
    AUTH0_CONTRIBUTOR_ROLE_ID                         = module.auth0.roles["contributor"]
    AUTH0_ISOLATED_CONTRIBUTOR_ROLE_ID                = module.auth0.roles["isolated-contributor"]
    AUTH0_GROUP_MANAGER_ROLE_ID                       = module.auth0.roles["group_manager"]
    AUTH0_SUBSIDIARY_MANAGER_ROLE_ID                  = module.auth0.roles["subsidiary_manager"]
    AUTH0_ADMIN_ROLE_ID                               = module.auth0.roles["admin"]
    AUTH0_SCS_SUPPLIER_RELATIONSHIP_MANAGER_ROLE_ID   = module.auth0.roles["scs_supplier_relationship_manager"]
    AUTH0_SCS_MODULE_MANAGER_ROLE_ID                  = module.auth0.roles["scs_module_manager"]
    AUTH0_GEN_PROFILE_MANAGER_ROLE_ID                 = module.auth0.roles["gen_profile_manager"]
    AUTH0_SUBSIDIARY_UNIT_MANAGER_ROLE_ID             = module.auth0.roles["subsidiary_unit_manager"]
    AUTH0_SUBSIDIARY_APPROVER_ROLE_ID                 = module.auth0.roles["subsidiary_approver"]
    AUTH0_CONSULTING_CLIENT_REPORTING_MANAGER_ROLE_ID = module.auth0.roles["consulting_client_reporting_manager"]
    AUTH0_CONSULTING_CLIENT_MANAGER_ROLE_ID           = module.auth0.roles["consulting_client_manager"]
    AUTH0_CLIENT_ID                                   = module.auth0.clients["web"]["client_id"]
    CORE_AUTH0_M2M_CLIENT_ID                          = module.auth0.clients["core"]["client_id"]
    CORE_AUTH0_M2M_CLIENT_SECRET                      = module.auth0.clients["core"]["client_secret"]
    CORE_AUTH0_M2M_AUDIENCE                           = module.auth0.resource_servers.core
    FRONTEND_URL                                      = "https://${var.identifier}.${local.domain}"
    SENDGRID_TOKEN                                    = var.sendgrid_token
    //noinspection HILConvertToHCL
    SINGLE_ORG                         = tostring(var.single_org)
    CORE_URL                           = var.core_api_url
    FRONTEND_DOMAIN                    = "${var.identifier}.${local.domain}"
    PORT                               = "80"
    ENABLE_LOGS                        = "true"
    ENABLE_MAIL_ON_ERROR               = "true"
    FEATURE_FLAG_FRAMEWORKS            = "1"
    NO_COLOR                           = "1"
    SERVER_ERROR_EMAIL_SENDER          = "serverlogs@daato.io"
    SERVER_ERROR_EMAILS                = "sreeganesh@daato.net mariusz.wozniak@codete.com maciej.chamera@codete.com emil.tomczuk@daato.net ilham.muhammad@daato.net giulia.fumagalli@daato.net alina.buzhynskaya@codete.com"
    PUBLIC_CONTAINER_CONNECTION_STRING = "DefaultEndpointsProtocol=https;AccountName=uploadtestforeng245;AccountKey=YYLUgWt+ftOx1p5S9FNNV4aKems0sZlclid9/PXait4zfG85kWrNgMoztb2dZbJKJB62DAvzgtf7+ASttsCruw==;EndpointSuffix=core.windows.net"
  }
}
