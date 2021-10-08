
variable "region" {
  default     = "us-west-1"
  description = "AWS region"
}
variable "user_id" {
  default = "ayushs" 
  type = string
  sensitive=false
}
variable "project_name" {
  default = "ayushsbankuno" 
  type = string
  sensitive=false
}
variable "environment" {
  default = "dev" 
  type = string
  sensitive=false
}
variable "cidr" {
  default = "172.16.8.0/22"
  type = string
  sensitive=false
}
variable "instance_type" {
  default = "m5a.xlarge"
  type = string
  sensitive=false
}                 
