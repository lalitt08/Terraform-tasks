variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  default = "10.0.4.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet2_cidr" {
  default = "10.0.3.0/24"
}

variable "elasticip" {
  default = "eipalloc-0906fc712cf2f1110"
}

variable "frontendami" {
  default = "ami-00e86b28eef799659"
}

variable "backendami" {
  default = "ami-0ecb1d91802e301d6"
}

variable "databaseami" {
  default = "ami-0617ba792dec09fbd"
}