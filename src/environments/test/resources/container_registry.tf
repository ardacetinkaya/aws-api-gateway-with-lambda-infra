resource "aws_ecr_repository" "test_repository" {
  name          = "testartifacts"
  provider      = aws.primary-region

  force_delete  = true

}