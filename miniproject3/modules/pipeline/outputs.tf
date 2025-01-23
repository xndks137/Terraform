output "pipeline_arn" {
  description = "ARN of the created pipeline"
  value       = aws_codepipeline.pipeline.arn
}

output "github_connection_arn" {
  description = "ARN of the GitHub connection"
  value       = aws_codestarconnections_connection.github.arn
}

output "artifact_bucket_name" {
  description = "Name of the artifact S3 bucket"
  value       = aws_s3_bucket.artifact_store.bucket
}