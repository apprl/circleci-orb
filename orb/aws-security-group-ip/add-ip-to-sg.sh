#!/bin/bash

current_security_group=$(aws ec2 describe-security-groups --region $AWS_DEFAULT_REGION --group-id $AWS_SECURITY_GROUP)
public_ip_address=$(wget -qO- http://checkip.amazonaws.com)
echo "This computers public ip address is $public_ip_address region $AWS_DEFAULT_REGION"
aws ec2 authorize-security-group-ingress --region $AWS_DEFAULT_REGION --group-id $AWS_SECURITY_GROUP --ip-permissions "[{\"IpProtocol\": \"tcp\", \"FromPort\": 443, \"ToPort\": 443, \"IpRanges\": [{\"CidrIp\": \"${public_ip_address}/32\"}]}]"
