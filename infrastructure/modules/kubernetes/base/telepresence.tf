resource "helm_release" "telepresence" {
  repository       = "https://app.getambassador.io"
  chart            = "telepresence"
  name             = "traffic-manager"
  namespace        = "ambassador"
  create_namespace = true
  wait             = true
}
