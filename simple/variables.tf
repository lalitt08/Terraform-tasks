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
  default = "eipalloc-0e40f346adb90d653"
}

variable "frontendami" {
  default = "ami-022c437c112e655ca"
}

variable "backendami" {
  default = "ami-022c437c112e655ca"
}

variable "databaseami" {
  default = "ami-022c437c112e655ca"
}
