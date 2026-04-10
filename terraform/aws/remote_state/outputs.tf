output "bucket_name" {
  description = "S3 bucket name — use in the Snowflake module backend config"
  value       = aws_s3_bucket.tfstate.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name — use in the Snowflake module backend config"
  value       = aws_dynamodb_table.tflock.name
}

output "region" {
  description = "AWS region"
  value       = var.region
}
