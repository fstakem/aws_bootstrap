#!/bin/bash

STACK_NAME=awsbootstrap
REGION=us-east-2
CLI_PROFILE=awsbootstrap

EC2_INSTANCE=t2.micro
AWS_ACCOUNT_ID=`aws sts get-caller-identity --profile awsbootstrap --query "Account" --output text`
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

echo -e "\n\n================| Deploying main.yaml |================"
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME-setup \
    --template-file setup.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        CodePipelineBucket=$CODEPIPLINE_BUCKET

aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME \
    --template-file main.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        EC2InstanceType=$EC2_INSTANCE

if [ $? -eq 0 ]; then
    aws cloudformation list-exports \
        --profile awsbootstrap \
        --query "Exports[?Name=='InstanceEndpoint'].Value"
fi