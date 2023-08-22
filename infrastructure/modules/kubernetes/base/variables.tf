variable "domain" {
  type = string
}
variable "daato_env" {
  type = string
}
variable "sendgrid_token" {
  type      = string
  sensitive = true
}
variable "is_local" {
  type    = bool
  default = false
}