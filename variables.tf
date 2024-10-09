variable "vpc_name" {
  description = "The name of the VPC."
  default     = "3tier-vpc"
}
variable "web_tier_cidr_block" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "app_tier_cidr_block" {
  default = ["10.10.4.0/24", "10.10.5.0/24"]
}

variable "db_tier_cidr_block" {
  default = ["10.10.7.0/24", "10.10.8.0/24"]
}