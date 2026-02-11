variable "function_name" { type = string }
variable "role_arn"       { type = string }
variable "env_vars"       { type = map(string) }

# ZIP-based settings (used only when package_type == "Zip")
variable "handler" {
  type    = string
  default = null
}

variable "runtime" {
  type    = string
  default = "python3.11"
}

variable "source_dir" {
  type    = string
  default = null
}

# Image-based settings (used only when package_type == "Image")
variable "package_type" {
  type    = string
  default = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be either 'Zip' or 'Image'."
  }
}

variable "image_uri" {
  type    = string
  default = null
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = coalesce(var.source_dir, "")
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.role_arn

  package_type = var.package_type

  # ZIP-based config (ignored when null)
  handler = var.package_type == "Zip" ? var.handler : null
  runtime = var.package_type == "Zip" ? var.runtime : null

  filename         = var.package_type == "Zip" ? data.archive_file.zip.output_path : null
  source_code_hash = var.package_type == "Zip" ? data.archive_file.zip.output_base64sha256 : null

  # Image-based config
  image_uri = var.package_type == "Image" ? var.image_uri : null

  environment {
    variables = var.env_vars
  }

  lifecycle {
    create_before_destroy = false
  }
}