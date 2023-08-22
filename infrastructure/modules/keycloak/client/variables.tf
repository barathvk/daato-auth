variable "realm" {
  type        = string
  description = "realm name"
}
variable "client_id" {
  type        = string
  description = "client id"
}
variable "access_type" {
  type        = string
  description = "CONFIDENTIAL or PUBLIC"
  default     = "CONFIDENTIAL"
}
variable "redirect_uris" {
  type    = list(string)
  default = ["*"]
}
variable "web_origins" {
  type    = list(string)
  default = ["*"]
}