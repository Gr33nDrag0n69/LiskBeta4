#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.1.1 (2023-06-01)

#---

echo "? Please enter LiskAddress:"
read -r LiskAddress

echo "? Please enter ValidatorName:"
read -r ValidatorName

echo "? Please enter passphrase:  [hidden]"
read -rs ValidatorPassphrase

echo "? Please enter password:  [hidden]"
read -rs ValidatorPassword

#---

OutputDirectory="$HOME/$ValidatorName-validator-backup/"
mkdir "$OutputDirectory"

ValidatorKeys_JsonFile=$OutputDirectory'keys.json'
HashOnionSeeds_JsonFile=$OutputDirectory'hash-onion-seeds.json'

#---

echo -e "2.1.1 Create the validator keys & save output to '$ValidatorKeys_JsonFile'"

lisk-core keys:create --output "$ValidatorKeys_JsonFile" --passphrase "$ValidatorPassphrase" --password "$ValidatorPassword"

echo -e "2.1.2 Show '$ValidatorKeys_JsonFile' content"

cat "$ValidatorKeys_JsonFile"

echo -e "2.2 Create the Register Validator transaction"

LiskKeys_JsonData=$( cat "$ValidatorKeys_JsonFile" )

GeneratedKeysAssociatedAddress=$( echo "$LiskKeys_JsonData" | jq '.keys[0].address' |  tr -d '"' )

if [ "$LiskAddress" != "$GeneratedKeysAssociatedAddress" ]; then
    echo -e "Error: The generated keys address don't match provided address."
    echo -e "If you are using a legacy address/passphrase, it's normal, it's not supported yet by this tool and won't be until 'keys:create' allows legacy derivation path."
    echo -e "If you are using a new address/phasphrase generated with lisk-core v4, it's NOT normal, Check your address again in lisk wallet using the passphrase and try again."
    exit 1
fi

ValidatorGeneratorKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.generatorKey' |  tr -d '"' )
ValidatorBlsKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsKey' |  tr -d '"' )
ValidatorProofOfPossession=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsProofOfPossession' |  tr -d '"' )

JsonParams='{"name":"'"$ValidatorName"'","generatorKey":"'"$ValidatorGeneratorKey"'","blsKey":"'"$ValidatorBlsKey"'","proofOfPossession":"'"$ValidatorProofOfPossession"'"}'
RegisterValidatorTransaction=$( lisk-core transaction:create pos registerValidator 1100000000 --params="$JsonParams" --passphrase "$ValidatorPassphrase" | jq '.transaction' |  tr -d '"' )

echo -e "2.3 Send the transaction"

lisk-core transaction:send "$RegisterValidatorTransaction"

echo -e "Wait 25 seconds (For transaction to get included in a block)"

sleep 25

echo -e "2.4 Show Validator Details (Post-Registration)"

JsonParams='{"address":"'"$LiskAddress"'"}'
lisk-core endpoint:invoke pos_getValidator "$JsonParams" --pretty

#---

echo -e "3.0 Import the validator keys"

lisk-core keys:import --file-path "$ValidatorKeys_JsonFile"

echo -e "3.1 Show Generator Imported Keys"

lisk-core endpoint:invoke generator_getAllKeys --pretty

#---

echo -e "4.0 Set the hash onion"

JsonParams='{"address":"'"$LiskAddress"'"}'
lisk-core endpoint:invoke random_setHashOnion "$JsonParams"

echo -e "4.1.1 Save hash onion seeds to '$HashOnionSeeds_JsonFile'"

lisk-core endpoint:invoke random_getHashOnionSeeds --pretty > "$HashOnionSeeds_JsonFile"

echo -e "4.1.2 Show '$HashOnionSeeds_JsonFile' content"

cat "$HashOnionSeeds_JsonFile"

#---

echo -e "6.0 Enable block generation for the first time (Using 0 0 0)"

lisk-core generator:enable "$LiskAddress" --height=0 --max-height-generated=0 --max-height-prevoted=0 --password "$ValidatorPassword"

#---

echo -e "7.0 SelfStake to increase the validator weight"

echo -e "7.1 Create the SelfStake Transaction (1000 LSK SelfStake using 1 LSK for Fees)"

JsonParams='{"stakes":[{"validatorAddress":"'"$LiskAddress"'","amount":100000000000}]}'
SelfStakeTransaction=$( lisk-core transaction:create pos stake 100000000 --params="$JsonParams" --passphrase "$ValidatorPassphrase" | jq '.transaction' |  tr -d '"' )

echo -e "7.2 Send the transaction"

lisk-core transaction:send "$SelfStakeTransaction"

echo -e "Wait 25 seconds (For transaction to get included in a block)"

sleep 25

echo -e "7.3 Show Validator Details (Post-SelfStake)"

JsonParams='{"address":"'"$LiskAddress"'"}'
lisk-core endpoint:invoke pos_getValidator "$JsonParams" --pretty

#---

echo ""
echo "IMPORTANT !!! Save a copy of '$OutputDirectory' to a safe location & delete it from the server."
echo ""
ls -l "$OutputDirectory"

#---
