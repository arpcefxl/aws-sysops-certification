#!/bin/bash

REGION1=$1
REGION2=$2

aws ec2 allocate-address --domain vpc --region $REGION1 --output text --query [PublicIp,NetworkBorderGroup]
aws ec2 allocate-address --domain vpc --region $REGION2 --output text --query [PublicIp,NetworkBorderGroup]
