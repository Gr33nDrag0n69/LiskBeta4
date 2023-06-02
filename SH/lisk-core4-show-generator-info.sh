#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.0.0 (2023-06-02)

#---

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[36m'
NOCOLOR='\033[0m'

#---

GeneratorStatus=$( lisk-core generator:status )

for Validator in $(echo "$GeneratorStatus" | jq -rc '.info.status[]'); do

    GeneratorAddress="$( echo "$Validator" | jq -r '.address' )"
    GeneratorName="$( lisk-core endpoint:invoke pos_getValidator '{"address":"'"$GeneratorAddress"'"}' | jq -r '.name' )"
    GeneratorEnabled="$( echo "$Validator" | jq -r '.enabled' )"

    #---

    printf "\n${CYAN}# Generator:${NOCOLOR} %s / %s\n" "$GeneratorName" "$GeneratorAddress"

    if [ "$GeneratorEnabled" = true ]
    then
        printf "\nCurrently ${GREEN}ACTIVE${NOCOLOR} on this node\n"
    else
        printf "\nCurrently ${CYAN}INACTIVE${NOCOLOR} on this node\n"
    fi

    #---

    LiskCore_GeneratorInfo=$( lisk-core generator:export | jq -c '.generatorInfo[] | select( .address == "'"$GeneratorAddress"'" )' )
    LiskCore_Height=$( echo "$LiskCore_GeneratorInfo" | jq '.height' )
    LiskCore_MaxHeightPrevoted=$( echo "$LiskCore_GeneratorInfo" | jq '.maxHeightPrevoted' )
    LiskCore_MaxHeightGenerated=$( echo "$LiskCore_GeneratorInfo" | jq '.maxHeightGenerated' )
    LiskCore_Warning=0

    LiskService_GeneratorInfo=$( curl -s "https://betanet-service.lisk.com/api/v3/blocks?generatorAddress=$GeneratorAddress&limit=1" )
    LiskService_Height=$( echo "$LiskService_GeneratorInfo" | jq '.data[0].height' )
    LiskService_MaxHeightPrevoted=$( echo "$LiskService_GeneratorInfo" | jq '.data[0].maxHeightPrevoted' )
    LiskService_MaxHeightGenerated=$( echo "$LiskService_GeneratorInfo" | jq '.data[0].maxHeightGenerated' )

    #---

    printf '\n'
    printf '                      Local Lisk-Core   Lisk-Service API\n'
    printf '             Height   '

    if [[ $LiskCore_Height -eq $LiskService_Height ]]
    then
        printf "${GREEN}%15s${NOCOLOR}   " "$LiskCore_Height"
        printf "${GREEN}%-15s${NOCOLOR}\n" "$LiskService_Height"
    elif [[ $LiskCore_Height -gt $LiskService_Height ]]
    then
        printf "${GREEN}%15s${NOCOLOR}   " "$LiskCore_Height"
        printf "${YELLOW}%-15s${NOCOLOR}\n" "$LiskService_Height"
    else
        LiskCore_Warning=1
        printf "${RED}%15s${NOCOLOR}   " "$LiskCore_Height"
        printf "${GREEN}%-15s${NOCOLOR}\n" "$LiskService_Height"
    fi

    printf '  MaxHeightPrevoted   '

    if [[ $LiskCore_MaxHeightPrevoted -eq $LiskService_MaxHeightPrevoted ]]
    then
        printf "${GREEN}%15s${NOCOLOR}   " "$LiskCore_MaxHeightPrevoted"
        printf "${GREEN}%-15s${NOCOLOR}\n" "$LiskService_MaxHeightPrevoted"
    elif [[ $LiskCore_MaxHeightPrevoted -gt $LiskService_MaxHeightPrevoted ]]
    then
        printf "${GREEN}%15s${NOCOLOR}   " "$LiskCore_MaxHeightPrevoted"
        printf "${YELLOW}%-15s${NOCOLOR}\n" "$LiskService_MaxHeightPrevoted"
    else
        LiskCore_Warning=1
        printf "${RED}%15s${NOCOLOR}   " "$LiskCore_MaxHeightPrevoted"
        printf "${GREEN}%-15s${NOCOLOR}\n" "$LiskService_MaxHeightPrevoted"
    fi

    printf ' MaxHeightGenerated   '

    if [[ $LiskCore_MaxHeightGenerated -eq $LiskService_MaxHeightGenerated ]]
    then
        printf "${GREEN}%15s${NOCOLOR}   " "$LiskCore_MaxHeightGenerated"
        printf "${GREEN}%-15s${NOCOLOR}\n" "$LiskService_MaxHeightGenerated"
    elif [[ $LiskCore_MaxHeightGenerated -gt $LiskService_MaxHeightGenerated ]]
    then
        printf "${GREEN}%15s${NOCOLOR}   " "$LiskCore_MaxHeightGenerated"
        printf "${YELLOW}%-15s${NOCOLOR}\n" "$LiskService_MaxHeightGenerated"
    else
        LiskCore_Warning=1
        printf "${RED}%15s${NOCOLOR}   " "$LiskCore_MaxHeightGenerated"
        printf "${GREEN}%-15s${NOCOLOR}\n" "$LiskService_MaxHeightGenerated"
    fi

    if [[ $LiskCore_Warning -eq 1 ]]
    then
        printf "\n${YELLOW}WARNING!!! Local value(s) are lower than on service!!!${NOCOLOR}\n"
    fi

    printf '\n'

done
