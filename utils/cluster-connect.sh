#!/bin/bash

set -e

region=eu-central-1
cluster_name=dev_eks_cluster
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve

aws eks update-kubeconfig --region $region --name $cluster_name