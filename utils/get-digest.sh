#!/bin/bash

set -e

# Extract the repository name from the URI
repo_uri="$1"
repo_name=$(echo "$repo_uri" | awk -F '/' '{print $2}')

image_digest=$(aws ecr describe-images --repository-name "$repo_uri" \
  --query 'imageDetails | sort_by(@, &imagePushedAt)[-1].imageDigest' --output text)

jq -n --arg digest "$image_digest" '{"digest":$digest}'
