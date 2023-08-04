#!/bin/bash

set -e

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <type: lambda|service> <name>"
    exit 1
fi

TYPE=$1
NAME=$2

# Determine the current script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get to the root directory from the script's location
ROOT_DIR=$(dirname "$DIR")

AWS_REGION="eu-central-1"
AWS_ACCOUNT_ID="304135002085"
URL_STRING=".dkr.ecr.$AWS_REGION.amazonaws.com"
IMAGE_STRING="latest"
ECR_IMAGE_URI="$AWS_ACCOUNT_ID$URL_STRING/$NAME:$IMAGE_STRING"

# Based on the type, set the path
if [ "$TYPE" == "lambda" ]; then
    PATH_TO_BUILD="$ROOT_DIR/lambdas/$NAME"
elif [ "$TYPE" == "service" ]; then
    PATH_TO_BUILD="$ROOT_DIR/services/$NAME"
else
    echo "Invalid type. Must be 'lambda' or 'service'."
    exit 1
fi

# Ensure the directory exists
if [ ! -d "$PATH_TO_BUILD" ]; then
    echo "Directory $PATH_TO_BUILD does not exist."
    exit 1
fi

# log in to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID$URL_STRING"

# Change to the directory containing the Dockerfile
cd "$PATH_TO_BUILD"

# build image
docker build --platform=linux/amd64 --tag "$NAME:test" .

# tag and push to AWS ECR
docker tag $NAME:test "$ECR_IMAGE_URI"
docker push "$ECR_IMAGE_URI"
