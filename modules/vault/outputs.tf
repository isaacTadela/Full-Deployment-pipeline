output "access_key" {
  value = module.vault.data.vault_aws_access_credentials.creds.access_key
}

output "secret_key" {
  value = module.vault.data.vault_aws_access_credentials.creds.secret_key
}
