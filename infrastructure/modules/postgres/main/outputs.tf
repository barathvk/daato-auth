output "password" {
  value = random_password.postgres.result
}
