## A learning journey for AWS API Gateway and Lambda w/ Terraform


- All provision is done with a bash `provision.sh`
    - It is a simple wrapper for `terraform` to have easy management of resource provosioning

### Folder structure

```yaml
- src
--- webapi        # Function apps.
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

- Execute the following command to take a `plan` for `test` environment

> ./provision.sh -a plan -e test`


- Sample output

```
Started... [2022-09-27 09:27:31]

+ resource "aws_api_gateway_deployment" "deployment_01"
 + resource "aws_api_gateway_integration" "integration_01"
 + resource "aws_iam_role" "iam_for_HelloLambda"
 + resource "aws_lambda_function" "hello_lambda"
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