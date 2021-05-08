#!/bin/bash

ZONE=$1

aws route53 create-hosted-zone --name $ZONE --caller-reference `date`
