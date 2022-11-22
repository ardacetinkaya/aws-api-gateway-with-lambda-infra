resource "aws_s3_bucket" "deployment_artifacts" {
  bucket = "deploymentartificats0001"
}

resource "aws_s3_bucket_notification" "bucket_notification_01" {
  bucket = aws_s3_bucket.deployment_artifacts.id
  
  queue {
    id            = "file-upload-event"
    queue_arn     = aws_sqs_queue.message_queue_01.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "files/"
  }
}