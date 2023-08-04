#!/bin/bash

set -e

aws s3 cp test.json s3://incoming-movie-data --acl bucket-owner-full-control
