#!/bin/bash

set -e

ln -s ~/.ssh/deploy ../modules/beancounter/files/deploy

packer-io build -machine-readable | tee packer.out
imageId=$(cat packer.out | grep 'amazon-ebs: AMIs were created' | cut -d ':' -f 4 | tr -d ' ')
rm packer.out

echo $imageId

exit

aws cloudformation create-stack \
 --profile trentinotv \
 --stack-name Blog --template-body "`cat cloudformation.json`" \
 --region eu-west-1 --capabilities="CAPABILITY_IAM" \
 --parameters ParameterKey=KeyName,ParameterValue=beancounter ParameterKey=ImageId,ParameterValue=$imageId
