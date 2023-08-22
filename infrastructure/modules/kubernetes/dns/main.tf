data "cloudflare_zones" "this" {
  filter {
    name = var.domain
  }
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    namespace = "ingress-nginx"
    name      = "ingress-nginx-controller"
  }
}
resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zones.this.zones[0].id
  name    = "*"
  value   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0]["ingress"][0].ip
  proxied = true
  type    = "A"
}
resource "cloudflare_record" "wildcard_auth" {
  zone_id = data.cloudflare_zones.this.zones[0].id
  name    = "*.auth"
  value   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0]["ingress"][0].ip
  proxied = true
  type    = "A"
}
resource "cloudflare_record" "ssh" {
  zone_id = data.cloudflare_zones.this.zones[0].id
  name    = "ssh"
  value   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0]["ingress"][0].ip
  proxied = false
  type    = "A"
}
