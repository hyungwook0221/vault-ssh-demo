resource "tls_private_key" "vault_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.vault_ssh_key.public_key_openssh
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vault" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "Vault-Server"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y unzip",
      "wget https://releases.hashicorp.com/vault/${var.vault_version}/vault_${var.vault_version}_linux_amd64.zip",
      "unzip vault_${var.vault_version}_linux_amd64.zip",
      "sudo mv vault /usr/local/bin/",
      "export VAULT_DEV_ROOT_TOKEN_ID=root",
      "vault server -dev -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200 &",
      "echo '${tls_private_key.vault_ssh_key.private_key_pem}' > /home/ubuntu/vault_ssh_key.pem",
      "chmod 600 /home/ubuntu/vault_ssh_key.pem"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault_ssh_key.private_key_pem
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "ssh_test" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "SSH-Test-Instance-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo adduser --disabled-password --gecos '' ${var.user_name}",
      "echo '${var.user_name}:${var.user_password}' | sudo chpasswd",
      "mkdir -p /home/${var.user_name}/.ssh",
      "echo '${tls_private_key.vault_ssh_key.public_key_openssh}' >> /home/${var.user_name}/.ssh/authorized_keys",
      "chown -R ${var.user_name}:${var.user_name} /home/${var.user_name}/.ssh",
      "chmod 600 /home/${var.user_name}/.ssh/authorized_keys"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault_ssh_key.private_key_pem
      host        = self.public_ip
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
