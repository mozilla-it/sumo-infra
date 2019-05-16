# ./50_cdn/user_media_s3
Note: The static user content IAM user credentials are not created here due to security concerns of the secret keys being stored in the terraform state. You will need to generate the credentials via the CLI or console separately and populate the kitsune secrets yaml

# ./99_jenkins
Note: the 'static_s3_prefix' in variables.tf must pattern match the naming schema in ./50_cdn/ for IAM permissions application.

```
variable "static_s3_prefix" {
  default = "mozit-sumo*-media*"
}
```


