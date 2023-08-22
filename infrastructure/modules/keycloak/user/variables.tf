variable "realm" {
  type        = string
  description = "realm name"
}
variable "username" {
  type = string
}
variable "password" {
  type    = string
  default = null
}
variable "email" {
  type = string
}
variable "first_name" {
  type = string
}
variable "last_name" {
  type = string
}