variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "public_key" {
  description = "SSH public key contents"
  type        = string
  sensitive   = true
}
