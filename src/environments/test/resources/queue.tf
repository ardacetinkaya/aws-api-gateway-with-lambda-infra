resource "aws_sqs_queue" "message_queue_01" {
  name                        = "test-queue-01"
  fifo_queue                  = false

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:test-queue-01",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.deployment_artifacts.arn}" }
      }
    }
  ]
}
POLICY
}