#!/bin/bash

set -e

cp -f ~/.ssh/deploy modules/beancounter_deploy/files/deploy

packer-io build -machine-readable --var-file secret.json packer.json | tee packer.out
imageId=$(cat packer.out | grep 'amazon-ebs: AMIs were created' | cut -d ':' -f 4 | tr -d ' ')
rm packer.out

echo $imageId

aws cloudformation create-stack \
 --profile trentinotv \
 --stack-name Beancounter --template-body "`cat cloudformation.json`" \
 --region eu-west-1 --capabilities="CAPABILITY_IAM" \
 --parameters ParameterKey=KeyName,ParameterValue=beancounter ParameterKey=ImageId,ParameterValue=ami-04c91173
