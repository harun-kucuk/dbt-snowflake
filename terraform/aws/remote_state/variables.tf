variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state — must be globally unique"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "sf-dbt-tflock"
}
