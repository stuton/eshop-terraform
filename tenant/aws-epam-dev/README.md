# AWS

If your domain was not purchased in AWS, then you need to create a [public hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html) in Route53 and delegate your domain to the Amazon NS server.

1. Create  for your domain 
2. cd tenant/aws-epam-dev/envs/dev
3. terragrunt run-all apply --terragrunt-non-interactive --terragrunt-include-external-dependencies
