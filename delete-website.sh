#!/usr/bin/env bash
set -euo pipefail

source env.sh

waitForStackSetInstanceToDelete () {
    STATUS="VARIABLE_INITIALISED"

    until [ "$STATUS" = "SUCCEEDED" ]
    do
        sleep 60

        STATUS=$(aws --region us-east-1 cloudformation describe-stack-set-operation \
                --stack-set-name $STACKSET_NAME \
                --operation-id $1 \
                | grep \"Status\" \
                | cut -d \" -f4)

        echo "Checking status of operation $1: $STATUS"
    done
}


# Cannot delete a non-empty bucket - delete objects first
echo "Deleting objects in site bucket $SITE_BUCKET_NAME"
aws --region eu-west-3 s3 rm --recursive s3://${SITE_BUCKET_NAME}

echo "Deleting Stack Set instances for $STACKSET_NAME - website infra"
OPERATION_ID=$(aws --region us-east-1 cloudformation delete-stack-instances \
    --stack-set-name $STACKSET_NAME \
    --accounts $ACCOUNT_ID \
    --regions eu-west-3 \
    --no-retain-stacks \
    | grep "OperationId" \
    | cut -d \" -f4)

echo "Delete Stack Set instance - operation ID: $OPERATION_ID"
echo "WARNING: This may take a long time!"
waitForStackSetInstanceToDelete $OPERATION_ID
echo "Operation ID: $OPERATION_ID complete"

echo "Deleting Stack Set $STACKSET_NAME"
aws --region us-east-1 cloudformation delete-stack-set \
    --stack-set-name $STACKSET_NAME

echo "Deleting Stack $SITE_STACK_NAME (SSL cert)"
aws --region us-east-1 cloudformation delete-stack --stack-name $SITE_STACK_NAME
