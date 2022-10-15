resource "aws_resourcegroups_group" "test" {
  name = "test-lambda-startup"
  provider = aws.primary-region

  resource_query {
      query = <<JSON
  {
      "ResourceTypeFilters": [
          "AWS::S3::Bucket",
          "AWS::Lambda::Function",
          "AWS::ApiGateway::RestApi",
          "AWS::ECR::Repository",
          "AWS::DynamoDB::Table"
      ],
      "TagFilters": [
          {
          "Key": "Environment",
          "Values": ["Test"]
          }
      ]
  }
  JSON
  }

  tags = {
      Name        = "Resources for testing AWS Lambda"
      Environment = "PoC"
  }
}
