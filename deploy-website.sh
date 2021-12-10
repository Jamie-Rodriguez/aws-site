#!/usr/bin/env bash
set -euo pipefail

source env.sh

echo "Deploying site stack $SITE_STACK_NAME"
aws --region us-east-1 cloudformation deploy \
    --template-file $STACKSET_CF_FILE \
    --stack-name $SITE_STACK_NAME \
    --parameter-overrides file://${CF_ENV_FILE}

echo "Uploading site files to $SITE_BUCKET_NAME"
aws --region eu-west-3 s3 cp site s3://${SITE_BUCKET_NAME} --recursive
aws --region eu-west-3 s3 ls s3://${SITE_BUCKET_NAME}
