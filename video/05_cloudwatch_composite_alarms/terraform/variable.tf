variable "cidr1_vpc" {
  description = "CIDR block for the VPC"
  default = "10.1.0.0/16"
}
variable "cidr1_subnet" {
  description = "CIDR block for the subnet"
  default = "10.1.0.0/24"
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  default = "us-east-1a"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
