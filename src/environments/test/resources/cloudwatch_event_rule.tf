resource "aws_cloudwatch_event_rule" "cloudwatch_event_rule" {
  name                = "batch-exec"
  schedule_expression = "cron(16,20,28 21-23 * * ? *)"
}

resource "aws_cloudwatch_event_target" "batch_target" {
  rule     = aws_cloudwatch_event_rule.cloudwatch_event_rule.name
  role_arn = aws_iam_role.task_execution_role.arn 
  arn      = aws_batch_job_queue.job_queue_01.arn
  batch_target {
    job_definition = aws_batch_job_definition.job_definition_01.arn
    job_name       = "test01"
  }
  
}