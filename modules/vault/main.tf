
resource "vault_aws_secret_backend" "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.region

  # 13min
  default_lease_ttl_seconds = "780" 
  max_lease_ttl_seconds = "780" 
}

resource "vault_policy" "example" {
  name = "ec2-node-policy"

  policy = <<EOT
path "aws/creds/ec2-node-role" {
    capabilities =["create", "read", "update", "delete", "list"] 
}

path "auth/token/renew-self" {
    capabilities = [ "update" ]
}	

path "auth/token/lookup-self" {
   capabilities = ["read"]
}
	
EOT
}

resource "vault_aws_secret_backend_role" "dev-admin" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "ec2-node-role"
  credential_type = "iam_user"
 
# Need: AmazonS3ReadOnlyAccess + CloudWatchReadOnlyAccess
# The policy generated for every ec2 machine 
# valid for how long???
policy_document= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*", "ec2:*", "rds:*", "elasticloadbalancing:*", "autoscaling:*", "cloudwatch:*",
     
        "s3:*",  
        "autoscaling:Describe",
        "autoscaling:Describe*",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "logs:Get*",
        "logs:List*",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:Describe*",
        "logs:TestMetricFilter",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "vault_aws_access_credentials" "creds" {
  backend = vault_aws_secret_backend.aws.path
  role    = vault_aws_secret_backend_role.dev-admin.name
}
