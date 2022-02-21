# CloudFormation template for a static site

This repo contains scripts and CloudFormation templates for automating the deployment and configuration for all the required resources to get a simple static site with SSL encryption up and running on AWS infrastructure.

*Note*: This configuration assumes you have purchased a domain through Route 53.

## Dependencies
`aws-cli` - To deploy the CloudFormation stacks through the CLI.

## Environmental Variables
The CloudFormation templates are supplied their parameters from the JSON file `.env.json` via the shell scripts. However the shell scripts also need to know several of these environment variables for deployment/teardown. As a result, the shell scripts read the shared variables from the JSON file, see `env.sh`.

*Note*: At time of writing CloudFormation external parameters are only supported in JSON format. See https://github.com/aws/aws-cli/issues/2275 for the status of this feature request.

## Problems
### ACM SSL Certificate Region
A hard requirement of AWS is that ACM certificates for CloudFront distributions be created in `us-east-1`. As I want to deploy all my resources (except the aforementioned certificate) to `eu-west-3`, this presents a problem as a CloudFormation Stack is not capable of multi-region deployment of resources. Because of this, we are forced to use *CloudFormation StackSets*.

### Using URL Paths Without `.html` Extension
In order to use URL paths *without* the `.html` extension e.g. `https://website.com/about`, instead of *only* being able to use `https://website.com/about.html` by default; I use a *CloudFront Function* to map the "*clean*" URLs to the corresponding `.html` file stored in S3. As this happens all within Amazon's network, the client does not see any of this indirection and to them, it "just works".

This function can be found in `urlRedirectFunction` of `website-infra.yaml`.

## Infrastructure Generated
The CloudFormation template `stackset.yaml` generates the following infrastructure stack as below:
```text
        eu-west-3         us-east-1
     +--------------+  +--------------+
     | Route 53 DNS |  | ACM SSL cert |
     +------+-------+  +------+-------+
            |                 |
      +-----V------+          |
      | CloudFront | <--------+
      +-----+------+
            |
+-----------V------------+
|  CloudFront Function   |
| (for redirecting URLs) |
+-----------+------------+
            |
           OAI
   (S3 Website endpoint)
            |
      +-----V-----+ (Bucket Policy blocks
      | S3 Bucket |  connections NOT from
      +-----+-----+  CloudFront OAI)
            |
            V
        index.html (Contained inside bucket)
```

## Infrastructure as Code (IaC) Files
### `stackset-deps.yaml`
Because we are using Stack Sets, we first have to provision the IAM Roles with relevant permissions required to deploy Stack Sets: `AWSCloudFormationStackSetAdministrationRole` and `AWSCloudFormationStackSetExecutionRole`.

Lastly, we require the website's IaC YAML file, `website-infra.yaml`, be saved into a bucket for the Stack Set to read from.

### `website-infra.yaml`
This file is not actually deployed on it's own. This IaC file defines the bulk of the resources. It defines all the infrastructure required to get a static site hosted on S3 up and running, *except* for the ACM SSL certificate. The certificate is referenced via CloudFormation parameters.

### `stackset.yaml`
This is the IaC file that gets deployed to provision the website resources. It creates two resources: the ACM SSL certificate and a Stack Set for the rest of the resources, contained in the previously-mentioned `website-infra.yaml`. However it does not read from the file *locally*, instead it reads from a copy uploaded to an S3 bucket in `stackset-deps.yaml`.

This file must be deployed to `us-east-1`, because AWS requires ACM certificates for CloudFront distributions *must* be deployed in `us-east-1`. As it's currently defined in the file, the Stack Set resource (i.e. the rest of the infrastructure) deploys to `eu-west-3`.

## Deployment Instructions
Pretty straightforward I think; run `deploy.sh` to deploy the website, and `teardown.sh` to delete all resources.
