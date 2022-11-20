resource "aws_batch_job_queue" "job_queue_01" {
  name     = "batch-job-queue-01"
  state    = "ENABLED"
  priority = 1

  compute_environments = [
    aws_batch_compute_environment.some_batch_compute_01.arn
  ]
}