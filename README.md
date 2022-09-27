## A learning journey for AWS API Gateway and Lambda w/ Terraform


- All provision is done with a bash `provision.sh`
    - It is a simple wrapper for `terraform` to have easy management of resource provosioning

### Folder structure

```yaml
- src
--- artifacts     #
--- environments  # Environment abstraction for provisioning
----- test        # Environment name can be 'test', 'prod', 'foo', 'xyz'...etc. 
------- _outputs    # Logs for terraform.
------- _temps      # Optional folder to have extra assets for terraform.
------- _plans      # Generated terraform plans that can be applied.
------- resources   # *.tf resources
--------- *.tf      # All terraform resource files are located in here.
----- prod         
------- _outputs    
------- _temps      
------- _plans      
------- resources   
--------- *.tf      
--- provision.sh  # bash script to run terraform commands
```
