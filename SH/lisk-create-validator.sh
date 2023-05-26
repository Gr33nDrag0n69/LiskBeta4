#!/bin/bash

# Lisk-Core v4 Beta 0
# Gr33nDrag0n v1.0 (2023-05-26)

#####################################################################################################################

echo "? Please enter ValidatorName:"
read -r ValidatorName

echo "? Please enter passphrase:  [hidden]"
read -rs ValidatorPassphrase

echo "? Please enter password:  [hidden]"
read -rs ValidatorPassword

echo -e "Create config/keys.json"
lisk-core keys:create --output config/keys.json --passphrase "$ValidatorPassphrase" --password "$ValidatorPassword"

echo -e "Parse config/keys.json"
LiskKeys_JsonData=$( cat config/keys.json )
ValidatorGeneratorKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.generatorKey' |  tr -d '"' )
ValidatorBlsKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsKey' |  tr -d '"' )
ValidatorProofOfPossession=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsProofOfPossession' |  tr -d '"' )
JsonParams='{"name":"'"$ValidatorName"'","generatorKey":"'"$ValidatorGeneratorKey"'","blsKey":"'"$ValidatorBlsKey"'","proofOfPossession":"'"$ValidatorProofOfPossession"'"}'

echo -e "Create Transaction"
Transaction=$( lisk-core transaction:create pos registerValidator 1100000000 --params="$JsonParams" --passphrase "$ValidatorPassphrase" | jq '.transaction' |  tr -d '"' )

echo -e "Send Transaction"
lisk-core transaction:send "$Transaction"
