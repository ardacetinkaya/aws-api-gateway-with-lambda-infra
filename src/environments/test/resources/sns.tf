resource "aws_sns_topic" "hello_world_topic_01" {
  name            = "hello_world_topic_01"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF

}

resource "aws_sns_topic_subscription" "sns_01_to_sqs_01" {
  topic_arn = aws_sns_topic.hello_world_topic_01.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.message_queue_01.arn
}

