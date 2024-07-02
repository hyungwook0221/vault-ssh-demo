variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-northeast-2" # Seoul region
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the subnet."
  type        = string
  default     = "ap-northeast-2a"
}

variable "instance_type" {
  description = "The type of instance to use."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair to use for the instances."
  type        = string
  default     = "vault-demo-key"
}

variable "vault_version" {
  description = "The version of Vault to install."
  type        = string
  default     = "1.9.0"
}

variable "user_name" {
  description = "The name of the user to create on SSH test instances."
  type        = string
  default     = "user01"
}

variable "user_password" {
  description = "The password for the user to create on SSH test instances."
  type        = string
  default     = "user01"
}
