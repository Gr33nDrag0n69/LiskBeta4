#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.0 (2023-05-28)

#---

GeneratorStatus=$( lisk-core generator:status )

for Validator in $(echo "$GeneratorStatus" | jq -rc '.info.status[]'); do

    ValidatorAddress="$( echo "$Validator" | jq -r '.address' )"
    ValidatorName="$( lisk-core endpoint:invoke pos_getValidator '{"address":"'"$ValidatorAddress"'"}' | jq -r '.name' )"
    GeneratorEnabled="$( echo "$Validator" | jq -r '.enabled' )"

    if [ "$GeneratorEnabled" = true ]
    then
        while true; do
            read -rp "Disable 'Generator Mode' on $ValidatorName ? y / n" yn
            case $yn in

                [Yy]* )
                    echo "CMD => lisk-core generator:disable $ValidatorAddress"
                    lisk-core generator:disable "$ValidatorAddress"
                    break
                ;;

                [Nn]* )
                    break
                    ;;

                * )
                    echo "Please answer (y)es or (n)o."
                    ;;
            esac
        done
    else
        echo "$ValidatorName 'Generator Mode' is already DISABLED. ($ValidatorAddress)"
    fi

done


