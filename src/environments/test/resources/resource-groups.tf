resource "aws_resourcegroups_group" "test" {
  name     = "test-lambda-startup"
  provider = aws.primary-region

  resource_query {
    query = <<JSON
  {
      "ResourceTypeFilters": [
          "AWS::S3::Bucket",
          "AWS::Lambda::Function",
          "AWS::ApiGateway::RestApi",
          "AWS::ECR::Repository",
          "AWS::DynamoDB::Table",
          "AWS::EKS::Cluster",
          "AWS::EC2::VPC",
          "AWS::EC2::Subnet",
          "AWS::EC2::RouteTable",
          "AWS::EC2::NetworkAcl",
          "AWS::EC2::SecurityGroup",
          "AWS::EC2::NatGateway",
          "AWS::EC2::EIP",
          "AWS::EC2::InternetGateway"
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
