#!/bin/bash

current_security_group=$(aws ec2 describe-security-groups --region $AWS_DEFAULT_REGION --group-id $AWS_SECURITY_GROUP)
echo "Security group config $current_security_group"
public_ip_address_with_cidr=$(wget -qO- http://checkip.amazonaws.com)/32
echo "My ip $public_ip_address_with_cidr"
ip_count=$(echo ${current_security_group} | jq -r '.SecurityGroups[0].IpPermissions | length')
if [[ ${ip_count} > 0 ]]; then
  for (( n=0; n < $ip_count; n++ ))
  do
    this_port=$(echo ${current_security_group} | jq -r ".SecurityGroups[0].IpPermissions[${n}].FromPort")
    cidr_count=$(echo ${current_security_group} | jq -r ".SecurityGroups[0].IpPermissions[${n}].IpRanges | length")
    for (( c=0; c < $cidr_count; c++ ))
    do
      this_cidr=$(echo ${current_security_group} | jq -r ".SecurityGroups[0].IpPermissions[${n}].IpRanges[${c}].CidrIp")
      if [[ "$this_cidr" == "$public_ip_address_with_cidr" ]] || [[ "$1" == "all" ]]; then
          echo "Revoke ip $this_cidr"
          aws ec2 revoke-security-group-ingress --region ${AWS_DEFAULT_REGION} --group-id $AWS_SECURITY_GROUP --protocol tcp --port ${this_port} --cidr ${this_cidr}
      fi
    done
  done
fi
