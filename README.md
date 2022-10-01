## A learning journey for AWS API Gateway and Lambda w/ Terraform

- I don't have any experience with `AWS Lambda` and `AWS API Gateway` so far.
    - So this is a simple repo. that I try to dig a little more. 😀🧑🏻‍💻
- For `AWS Lambda` functions I have choosen .NET Platform to see what is required for .NET aspect
    - I have also tried `Amazon.Lambda.Tools` tool for .NET

        > dotnet tool update -g Amazon.Lambda.Tools
    
    - I have done with standart ASP.NET Core Web API and with some other project templates that can be installed via;

        > dotnet new --install Amazon.Lambda.Templates

- Also for deployments and container image builds, `GitHub Actions` are used

- All provision is done with a bash `provision.sh`
    - It is a simple wrapper for `terraform` to have easy management of resource provosioning

### Folder structure

```yaml
- src
--- functions        # Function apps.
--- environments  # Environment abstraction for provisioning
----- test        # Environment name can be 'test', 'prod', 'foo', 'xyz'...etc. 
------- _outputs  # Logs for terraform.
------- _temps    # Optional folder to have extra assets for terraform.
------- _plans    # Generated terraform plans that can be applied.
------- resources # *.tf resources
--------- *.tf    # All terraform resource files are located in here.
----- prod         
------- _outputs    
------- _temps      
------- _plans      
------- resources   
--------- *.tf      
--- provision.sh  # bash script to run terraform commands
```

### Provisioning the resources
----------------------
- I have created a simple `bash` script to wrap `terraform`
    - I don't have some much experience with writing `a good` bash script, so please feel free to help me do 😀 😀 😀
    
- Execute the following command to take a `plan` for `test` environment

    > ./provision.sh -a plan -e test`

- Sample output

    ```
    Started... [2022-09-27 09:27:31]

    + resource "aws_api_gateway_deployment" "deployment_01"
     + resource "aws_api_gateway_integration" "integration_01"
     + resource "aws_iam_role" "iam_for_HelloLambda"
     + resource "aws_lambda_function" "hello_lambda_v1"
     + resource "aws_lambda_function_url" "hello_lambda_url"
     + resource "aws_lambda_permission" "apigw_lambda"
     + resource "aws_resourcegroups_group" "test"
     ............
     .........
     ....

     Plan: 18 to add, 0 to change, 0 to destroy.
    ------------------------------------------------------------------------------
    Plan: /workspaces/aws-api-gateway-with-lambda-infra/src/environments/test/_plans/test-plan-1664270851.tfplan
    Log: /workspaces/aws-api-gateway-with-lambda-infra/src/environments/test/_outputs/20220927/test-plan-1664270851.log
    ------------------------------------------------------------------------------
    Finished.  [2022-09-27 09:27:34]
    ------------------------------------------------------------------------------

    Please check plan output. If plan is correct, apply it;

           ./provision.sh -a apply -e test -t 1664270851

    ------------------------------------------------------------------------------
    ``` 

- If plan seems to be fine then execute following to `apply` the plan

    > ./provision.sh -a apply -e test -t 1664270851

### Functions
----------------------
- Different .NET application models are used for `AWS Lambda`
- Within some `AWS Lambda` requierments different kind of APIs and models are required
