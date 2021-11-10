#!/usr/bin/env bash
set -euo pipefail

source env.sh

echo "Deploying stack $STACKSET_DEPS_STACK_NAME"
# Require --capabilities CAPABILITY_NAMED_IAM because this stack creates
# IAM roles required for StackSets
aws --region eu-west-3 cloudformation deploy \
    --capabilities CAPABILITY_NAMED_IAM \
    --template-file $STACKSET_DEPS_CF_FILE \
    --stack-name $STACKSET_DEPS_STACK_NAME \
    --parameter-overrides file://${CF_ENV_FILE}

echo "Uploading $SITE_CF_FILE to $STACKSET_DEPS_BUCKET_NAME"
aws --region eu-west-3 s3 cp $SITE_CF_FILE s3://${STACKSET_DEPS_BUCKET_NAME}
aws --region eu-west-3 s3 ls s3://${STACKSET_DEPS_BUCKET_NAME}
