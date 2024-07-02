output "vault_instance_public_ip" {
  value = aws_instance.vault.public_ip
}

output "ssh_test_instance_public_ips" {
  value = aws_instance.ssh_test[*].public_ip
}
