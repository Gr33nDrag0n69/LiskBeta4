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

echo -e "2.1 Create the validator keys (config/keys.json)"

lisk-core keys:create --output config/keys.json --passphrase "$ValidatorPassphrase" --password "$ValidatorPassword"

echo -e "2.2 Create the Register Validator transaction"

LiskKeys_JsonData=$( cat config/keys.json )
ValidatorGeneratorKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.generatorKey' |  tr -d '"' )
ValidatorBlsKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsKey' |  tr -d '"' )
ValidatorProofOfPossession=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsProofOfPossession' |  tr -d '"' )
JsonParams='{"name":"'"$ValidatorName"'","generatorKey":"'"$ValidatorGeneratorKey"'","blsKey":"'"$ValidatorBlsKey"'","proofOfPossession":"'"$ValidatorProofOfPossession"'"}'
Transaction=$( lisk-core transaction:create pos registerValidator 1100000000 --params="$JsonParams" --passphrase "$ValidatorPassphrase" | jq '.transaction' |  tr -d '"' )

echo -e "2.3 Send the transaction"

lisk-core transaction:send "$Transaction"

echo -e "3.0 Import the validator keys"

lisk-core keys:import --file-path ./config/keys.json

echo -e "3.1. Verifying correct import"

lisk-core endpoint:invoke generator_getAllKeys --pretty
