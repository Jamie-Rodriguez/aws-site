#!/usr/bin/env bash
set -euo pipefail

export CF_ENV_FILE=.env.json

# We have to do this to retrieve the S3 bucket names from
# the CloudFormation parameters JSON file.
# This is because the CLI scripts also need to know the bucket names when deleting the stacks:
# CloudFormation cannot delete a non-empty bucket.
# In order to remove the objects from the bucket,
# the CLI also needs to know the bucket name
readValueFromCfEnvFile () {
    # cat ${CF_ENV_FILE} \
    #     | jq --raw-output '.[] | select(.ParameterKey | contains('"\"$1\""')) | .ParameterValue'
    cat $CF_ENV_FILE \
        | grep --after-context=1 \"$1\" \
        | tail -n 1 \
        | cut -d \" -f4
}

export STACKSET_DEPS_CF_FILE=stackset-deps.yaml
export STACKSET_DEPS_BUCKET_NAME=$(readValueFromCfEnvFile "stacksetBucketName")
export STACKSET_DEPS_STACK_NAME=CHANGE_ME

export STACKSET_CF_FILE=stackset.yaml

export SITE_CF_FILE=$(readValueFromCfEnvFile "websiteCfFile")
export SITE_BUCKET_NAME=$(readValueFromCfEnvFile "domain")
export SITE_STACK_NAME=CHANGE_ME

# These are used for deleting the StackSet
export ACCOUNT_ID=$(readValueFromCfEnvFile "administratorAccountId")
export STACKSET_NAME=$(readValueFromCfEnvFile "stacksetName")
