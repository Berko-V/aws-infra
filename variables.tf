variable "project" {
  type    = string
  default = "free-tier-demo"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "lambda_root_package_type" {
  type    = string
  default = "Zip"
}

variable "lambda_root_image_uri" {
  type    = string
  default = null
}