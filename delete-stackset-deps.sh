#!/usr/bin/env bash
set -euo pipefail

source env.sh

# Cannot delete a non-empty bucket - delete objects first
echo "Deleting CloudFormation template from S3 bucket $STACKSET_DEPS_BUCKET_NAME"
aws --region eu-west-3 s3 rm --recursive s3://${STACKSET_DEPS_BUCKET_NAME}

echo "Deleting \"Stack Set dependencies\" stack $STACKSET_DEPS_STACK_NAME"
aws --region eu-west-3 cloudformation delete-stack --stack-name $STACKSET_DEPS_STACK_NAME