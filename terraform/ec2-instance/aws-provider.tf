provider "aws" {
    access_key = "<key>"
    secret_key = "<secret>"

    # Tell terraform to 'talk' with symphony
    endpoints {
        ec2 = "http://<cluster ip>/api/v2/ec2"
    }

    insecure = "true"
    skip_metadata_api_check = true
    skip_credentials_validation = true

    # No importance for this value currently
    region = "eu-west-1"
}