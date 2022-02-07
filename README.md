# terraform-lambda-webapp

## Generate a Terraform Cloud user API token and store it as a GitHub secret  TF_API_TOKEN on this repository.
   Documentation:
     - https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html
     - https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets

##Provide Terraform organisation and workspace in main.tf like below, replace the values for running it with a different terraform account.

terraform {
  cloud { 
    organization = "kuber24"

    workspaces {
      name = "web-app"
    }
  }
}

## Login to the terraform cloud and go to the organisation > workspace > variables and create below two workspace environment variables with proper values

       1.  AWS_ACCESS_KEY_ID
       2.  AWS_SECRET_ACCESS_KEY

Every push to main branch will deploy the infra change as well as change in the folder web-app

## how to access api
You can access the web app using "base_url" which you will see as the terraform plan build stage output along with a path "/api"

##Test case 

curl --header "Content-Type: application/json" --data '{"username":"xyz","password":"xyz"}' base_url/api



