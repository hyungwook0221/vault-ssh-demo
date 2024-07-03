output "vault_instance_public_ip" {
  value = aws_instance.vault.public_ip
}

output "ssh_test_instance_public_ips" {
  value = aws_instance.ssh_test[*].public_ip
}

output "vault_ssh_private_key" {
  value     = tls_private_key.vault_ssh_key.private_key_pem
  sensitive = true
}

output "vault_ssh_public_key" {
  value = tls_private_key.vault_ssh_key.public_key_openssh
}
