# terraform-lambda-webapp

## Stacks used:

1. Terraform
2. GitHub Actions
3. AWS Lambda
4. AWS api gateway
5. terraform cloud
6. s3 bucket

The repository will deploy any changes to the cloud infra as well as simple web app.

## Generate a Terraform Cloud user API token and store it as a GitHub secret  TF_API_TOKEN on this repository.
   Documentation:
     - https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html
     - https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets

##Provide Terraform organisation and workspace in main.tf like below, replace the values for running it with a different terraform account.

```
terraform {
  cloud { 
    organization = "kuber24"

    workspaces {
      name = "web-app"
    }
  }
}
```
## Login to the terraform cloud and go to organisation > workspace > variables and create below two workspace environment variables with proper values

       1.  AWS_ACCESS_KEY_ID
       2.  AWS_SECRET_ACCESS_KEY

Every push to main branch will deploy the infra change as well as change in the folder web-app

## how to access api
You can access the web app using "base_url" which you will see as the terraform plan build stage output along with a path "/api"

##Test case 

curl --header "Content-Type: application/json" --data '{"username":"xyz","password":"xyz"}' base_url/api

## Destroy the resources

Haven't added any conditions to the pipeline for it, but you can destory it by adding below to the terraform.yml pipeline and push to destory

```
    - name: Terraform Apply
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: terraform apply -auto-approve

```

