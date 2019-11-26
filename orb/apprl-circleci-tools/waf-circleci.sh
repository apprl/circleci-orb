#!/bin/bash

DEBUGMODE="1"


#circleCi IPSetID
IPSETID="241257cc-9a9d-4409-be3e-9e39c75b3381"

# Gets a Change Token
function ChangeToken(){
	CHANGETOKEN=$(aws waf get-change-token | jq '.ChangeToken' | cut -d '"' -f2)
	if [[ $DEBUGMODE = "1" ]]; then
		echo "CHANGE TOKEN: "$CHANGETOKEN
	fi
}

# Gets IPSET from IPSetId
function GetCurrentIpFromIPSetId(){
	IPLIST=$(aws waf get-ip-set --ip-set-id $IPSETID  | jq '.IPSet' | jq '.IPSetDescriptors')
	if [[ $DEBUGMODE = "1" ]]; then
		echo "IPLIST: "$IPLIST
	fi
}

# Get circleCi IPv4 IPs
function GetIP(){
	IP=$(wget -qO- http://checkip.amazonaws.com)"/32"

    if [[ $DEBUGMODE = "1" ]]; then
		echo "CircleCi IP: "$IP
	fi
}

# Fail
function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

# Checks the status of a single changetoken
function CheckStatus(){
    CHANGETOKENSTATUS="PENDING"
    INDEX=0
	echo "Checking Status:"
    while [[ ${CHANGETOKENSTATUS} == "PENDING" && ${INDEX} -le 6 ]]; do
        CHANGETOKENSTATUS=$(aws waf get-change-token-status --change-token ${CHANGETOKEN} | jq '.ChangeTokenStatus' | cut -d '"' -f2)
        printf '.'
        INDEX=$((INDEX + 1))
#        echo ${INDEX}
        sleep 5
    done
    echo "\n"${CHANGETOKENSTATUS}
}

# Inserts a single IP getting from get method GetIP -> $IP
function InsertIPSet(){
	ChangeToken
	GetIP
	if [[ $DEBUGMODE = "1" ]]; then
		echo "IPSETID: "$IPSETID
		echo "IPS: " $IP
	fi
	UPDATESET=$(aws waf update-ip-set --ip-set-id $IPSETID --change-token $CHANGETOKEN --updates 'Action=INSERT,IPSetDescriptor={Type=IPV4,Value="'"$IP"'"}' 2>&1) # | jq .)

	if echo $UPDATESET | grep -q error; then
		fail "$UPDATESET"
	else
		if [[ $DEBUGMODE = "1" ]]; then
			echo "UPDATESET: "$UPDATESET
		fi
#		CheckStatus
	fi

	if [[ $DEBUGMODE = "1" ]]; then
	    echo "$UPDATESET"
	fi
}

# Deletes IPS from list GetCurrentIpFromIPSetId -> IPSLIST
function DeleteIPSet(){
	ChangeToken
	GetCurrentIpFromIPSetId
	if [[ $DEBUGMODE = "1" ]]; then
		echo "IPSETID: "$IPSETID
		echo "IP: "$IPLIST
	fi

	if [[ -n "$IPLIST" ]]; then
	    # better way to do it but only works in jq 1.6 version
        # echo "$IPLIST" | jq 'map(. + {IPSetDescriptor: (.)})' | jq 'map(. + {Action: ("DELETE")})' | jq 'walk(if type == "object" and length != 2 then del(.Type?, .Value?) else . end)'
        UPDATESET=$(aws waf update-ip-set --ip-set-id ${IPSETID} --change-token ${CHANGETOKEN} --updates "$(echo "$IPLIST"| jq '[.[] | { IPSetDescriptor: {Type: .IPSetDescriptor.Type, Value: .IPSetDescriptor.Value}, Action: "DELETE"}]' --slurp)" 2>&1) # | jq .)

        if echo $UPDATESET | grep -q error; then
            fail "$UPDATESET"
        else
            if [[ $DEBUGMODE = "1" ]]; then
                echo "UPDATESET: "$UPDATESET
            fi
#    		CheckStatus
        fi

        if [[ $DEBUGMODE = "1" ]]; then
            echo "$UPDATESET"
        fi
    fi
}
GetCurrentIpFromIPSetId

echo "$IPLIST"| jq '[.[] | { IPSetDescriptor: {Type: .[].Type, Value: .[].Value}, Action: "DELETE"}]' --slurp
#echo "$IPLIST"| jq '[.[] ]'
#DeleteIPSet
#InsertIPSet