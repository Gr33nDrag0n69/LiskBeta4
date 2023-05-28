#!/bin/bash

# Lisk-Core v4 Beta 0
# Gr33nDrag0n v1.0 (2023-05-26)

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

echo -e "2.1.1 Create the validator keys & save output to '~/config/ValidatorKeys.json'"

lisk-core keys:create --output ~/config/ValidatorKeys.json --passphrase "$ValidatorPassphrase" --password "$ValidatorPassword"

echo -e "2.1.2 Show '~/config/ValidatorKeys.json' content"

cat ~/config/ValidatorKeys.json

echo -e "2.2.1 Create the Register Validator transaction"

LiskKeys_JsonData=$( cat ~/config/ValidatorKeys.json )
ValidatorGeneratorKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.generatorKey' |  tr -d '"' )
ValidatorBlsKey=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsKey' |  tr -d '"' )
ValidatorProofOfPossession=$( echo "$LiskKeys_JsonData" | jq '.keys[0].plain.blsProofOfPossession' |  tr -d '"' )

JsonParams='{"name":"'"$ValidatorName"'","generatorKey":"'"$ValidatorGeneratorKey"'","blsKey":"'"$ValidatorBlsKey"'","proofOfPossession":"'"$ValidatorProofOfPossession"'"}'
RegisterValidatorTransaction=$( lisk-core transaction:create pos registerValidator 1100000000 --params="$JsonParams" --passphrase "$ValidatorPassphrase" | jq '.transaction' |  tr -d '"' )

echo -e "2.2.2 Save Register Validator Transaction to '~/config/RegisterValidatorTransaction.json'"

echo -e "$RegisterValidatorTransaction" > ~/config/RegisterValidatorTransaction.json

echo -e "2.2.3 Show '~/config/RegisterValidatorTransaction.json'"

cat ~/config/RegisterValidatorTransaction.json

echo -e "2.3 Send the transaction"

lisk-core transaction:send "$RegisterValidatorTransaction"

echo -e "Wait 25 seconds (For transaction to get included in a block)"

sleep 25

echo -e "2.4.1 Save validator details to '~/config/ValidatorDetails.json'"

JsonParams='{"address":"'"$LiskAddress"'"}'
lisk-core endpoint:invoke pos_getValidator "$JsonParams" --pretty > ~/config/ValidatorDetails.json

echo -e "2.4.2 Show '~/config/ValidatorDetails.json' content"

cat ~/config/ValidatorDetails.json

#---

echo -e "3.0 Import the validator keys"

lisk-core keys:import --file-path ~/config/ValidatorKeys.json

echo -e "3.1.1 Save Generator Imported Keys to '~/config/GeneratorImportedKeys.json'"

lisk-core endpoint:invoke generator_getAllKeys --pretty > ~/config/GeneratorImportedKeys.json

echo -e "3.1.2 Show '~/config/GeneratorImportedKeys.json' content"

cat ~/config/GeneratorImportedKeys.json

#---

echo -e "4.0 Set the hash onion"

JsonParams='{"address":"'"$LiskAddress"'"}'
lisk-core endpoint:invoke random_setHashOnion "$JsonParams"

echo -e "4.1.1 Save hash onion seeds to '~/config/HashOnionSeeds.json'"

lisk-core endpoint:invoke random_getHashOnionSeeds --pretty > ~/config/HashOnionSeeds.json

echo -e "4.1.2 Show '~/config/HashOnionSeeds.json' content"

cat ~/config/HashOnionSeeds.json

#---

echo -e "6.0 Enable block generation for the first time (Using 0 0 0)"

lisk-core generator:enable "$LiskAddress" --height=0 --max-height-generated=0 --max-height-prevoted=0 --password "$ValidatorPassword"

#---

echo -e "7.0 SelfStake to increase the validator weight"

echo -e "7.1.1 Create the SelfStake Transaction (1000 LSK SelfStake using 1 LSK for Fees)"

JsonParams='{"stakes":[{"validatorAddress":"'"$LiskAddress"'","amount":100000000000}]}'
SelfStakeTransaction=$( lisk-core transaction:create pos stake 100000000 --params="$JsonParams" --passphrase "$ValidatorPassphrase" | jq '.transaction' |  tr -d '"' )

echo -e "7.1.2 Save SelfStake Transaction to '~/config/SelfStakeTransaction.json'"

echo -e "$SelfStakeTransaction" > ~/config/SelfStakeTransaction.json

echo -e "7.1.3 Show '~/config/SelfStakeTransaction.json'"

cat ~/config/SelfStakeTransaction.json

echo -e "7.2 Send the transaction"

lisk-core transaction:send "$SelfStakeTransaction"

echo -e "Wait 25 seconds (For transaction to get included in a block)"

sleep 25

echo -e "7.3.1 Save SelfStake validator details to '~/config/SelfStakeValidatorDetails.json'"

JsonParams='{"address":"'"$LiskAddress"'"}'
lisk-core endpoint:invoke pos_getValidator "$JsonParams" --pretty > ~/config/SelfStakeValidatorDetails.json

echo -e "7.3.2 Show '~/config/SelfStakeValidatorDetails.json' content"

cat ~/config/SelfStakeValidatorDetails.json

#---

echo ""
echo "IMPORTANT !!!"
echo ""
echo "In theory, from now on (The keys are imported on the nodes), you don't need the clear-text files on the server in the '~/config/' directory."
echo ""
ls -l ~/config/
echo ""
echo "For security purpose, save a copy of the file(s) to a safe location & delete them from the server."
echo "Make sure to backup them even if you leave them on the server since if you want to restore the server or use the validator on another node, you will need part of these informations."
echo ""

#---
