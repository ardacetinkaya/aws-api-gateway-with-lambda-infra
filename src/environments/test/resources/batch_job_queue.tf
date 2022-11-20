resource "aws_batch_job_queue" "job_queue_01" {
  name     = "${local.job_queue_name}"
  state    = "ENABLED"
  priority = 1

  compute_environments = [
    aws_batch_compute_environment.some_batch_compute_01.arn
  ]
}