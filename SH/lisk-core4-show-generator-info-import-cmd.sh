#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.0.0 (2023-06-02)

#---

#RED='\033[0;31m'
GREEN='\033[0;32m'
#YELLOW='\033[0;33m'
CYAN='\033[36m'
NOCOLOR='\033[0m'

#---

GeneratorStatus=$( lisk-core generator:status )

for Validator in $(echo "$GeneratorStatus" | jq -rc '.info.status[]'); do

    GeneratorAddress="$( echo "$Validator" | jq -r '.address' )"
    GeneratorName="$( lisk-core endpoint:invoke pos_getValidator '{"address":"'"$GeneratorAddress"'"}' | jq -r '.name' )"

    printf "\n${CYAN}# Generator:${NOCOLOR} %s / %s\n\n" "$GeneratorName" "$GeneratorAddress"

    GeneratorInfo=$( lisk-core generator:export | jq -c '.generatorInfo[] | select( .address == "'"$GeneratorAddress"'" )' )
    Height=$( echo "$GeneratorInfo" | jq '.height')
    MaxHeightGenerated=$( echo "$GeneratorInfo" | jq '.maxHeightGenerated')
    MaxHeightPrevoted=$( echo "$GeneratorInfo" | jq '.maxHeightPrevoted')
    GeneratorInfoJson='{"generatorInfo": [{"address": "'"$GeneratorAddress"'","height": '"$Height"',"maxHeightGenerated": '"$MaxHeightGenerated"',"maxHeightPrevoted": '"$MaxHeightPrevoted"'}]}'

    printf "${GREEN}--------------------------------------------------------------------------------${NOCOLOR}\n"
    echo "Json='$GeneratorInfoJson'"
    echo 'echo "$Json" > "$HOME/generatorInfo.tmp"'
    echo 'lisk-core generator:import -f "$HOME/generatorInfo.tmp"'
    echo 'rm -f "$HOME/generatorInfo.tmp"'
    printf "${GREEN}--------------------------------------------------------------------------------${NOCOLOR}\n\n"

done
