#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.0.1 (2023-06-14)

#---

# TODO !! delegate should always pick the local data, unless its somehow lower than on service
# Using lisk service, validate the 3 critical values are similar.
# If not, show a warning!

#---

# Default Configuration

# Save your encryption password here to allow automatic enabling. (Optional)
EncryptionPassword=""

LiskCoreBinaryFullPath="$HOME/lisk-core/bin/lisk-core"
WaitDelay=0
RetryDelay=180
MaxRetry=20
Debug=false

#------------------------------------------------------------------------------

if [ ! -f "$LiskCoreBinaryFullPath" ]
then
    echo "Error: lisk-core Binary NOT FOUND! Edit 'LiskCoreBinaryFullPath' value & retry. Aborting..." >&2
    exit 1
fi

if [ $WaitDelay -gt 0 ]
then
    echo "Waiting $WaitDelay second(s) before execution."
    sleep $WaitDelay
fi

ChainID=$( "$LiskCoreBinaryFullPath" system:node-info 2>/dev/null | jq -r '.chainID' |  tr -d '"' )

if [ -z "$ChainID" ]
then
    echo "Error: 'lisk-core system:node-info' is empty. Validate the lisk-core process is currently running." >&2
    exit 1
fi

case $ChainID in
    # Betanet
    "02000000")
        echo "ChainID: $ChainID | Lisk-Core4 BetaNet"
        #TopHeightUrl="https://betanet.lisk.com/rpc"
        TopHeightUrl="https://beta4-api.lisknode.io/rpc"
        MinHeight=100000
        ;;

    # Invalid ChainID
    *)
        echo "Error: 'lisk-core system:node-info' ChainID is UNKKNOWN. (To this script)" >&2
        exit 1
        ;;
esac

###############################################################################
### FUNCTIONS

parse_option() {

    while [[ $1 = -?* ]]
    do
        case "$1" in
            -p | --password) shift; EncryptionPassword="${1}" ;;
            -b | --binarypath) shift; LiskCoreBinaryFullPath="${1}" ;;
            -w | --wait) shift; WaitDelay="${1}" ;;
            -r | --retrydelay) shift; RetryDelay="${1}" ;;
            -m | --maxretry) shift; MaxRetry="${1}" ;;
            -a | --api) shift; TopHeightUrl="${1}" ;;
            -h | --help) usage; exit 1 ;;
            -d | --debug) Debug=true ;;
            --endopts) shift; break ;;
            *) echo "invalid option: '$1'."; exit 1 ;;
            esac
        shift
    done
}

usage() {
      cat <<EOF_USAGE
Usage: $0 [-p "EncryptionPassword"] [-b "LiskCoreBinaryFullPath"] [-w WaitDelay] [-r RetryDelay] [-m MaxRetry] [-a "TopHeightUrl"] [-d]

Available options:

-p, --password "EncryptionPassword"

    Encryption Password.
    Default value: '$EncryptionPassword'.

-b, --binarypath "LiskCoreBinaryFullPath"

    Full path of the lisk-core binary.
    Default value: '$LiskCoreBinaryFullPath'.

-w, --wait WaitDelay

    Automation: Wait X seconds. Allow the lisk-core process to start before execution of this script.
    If using this script with a cronjob, make sure to set this value to at least 3 seconds.
    Default value: '$WaitDelay'.

-r, --retrydelay RetryDelay

    Automation: If node is syncing, retry each X seconds.
    Default value: '$RetryDelay'.

-m, --maxretry MaxRetry

    Automation: Max number of retry.
    Default value: '$MaxRetry'.

-a, --api "TopHeightUrl"

    The script check for TopHeight using this API URL.
    Default value: '$TopHeightUrl'.

    Public Nodes:

        # Beta Net
        lisk.com    : https://betanet.lisk.com/rpc
        gr33ndrag0n : https://beta4-api.lisknode.io/rpc

-d, --debug

    Developer: Enable DEBUG mode. Skip 'lisk-core generator:enable' command execution.

EOF_USAGE

}

###############################################################################
### MAIN CODE

parse_option "$@"

CurrentTry=1

until [ "$CurrentTry" -gt "$MaxRetry" ]
do
    NodeInfo=$( "$LiskCoreBinaryFullPath" endpoint:invoke system_getNodeInfo 2>/dev/null )

    if [ -z "$NodeInfo" ]
    then
        echo "Error: 'lisk-core endpoint:invoke system_getNodeInfo' is empty. Validate the lisk-core process is currently running." >&2
        exit 1
    else
        NodeSyncing=$( echo "$NodeInfo" | jq -r '.syncing' )

        PublicNodeInfo_JsonParams='{"jsonrpc":"2.0","id":"1","method":"system_getNodeInfo","params":{}}'
        PublicNodeInfo=$( curl --silent --location --request GET "$TopHeightUrl" --header 'Content-Type: application/json' --data-raw "$PublicNodeInfo_JsonParams" )
        TopHeight=$( echo "$PublicNodeInfo" | jq -r '.result.height' )

        if [ "$NodeSyncing" = false ]
        then
            NodeHeight=$( echo "$NodeInfo" | jq -r '.height' )

            if [ "$NodeHeight" -gt "$MinHeight" ]
            then
                GeneratorStatus=$( "$LiskCoreBinaryFullPath" generator:status )

                for Validator in $(echo "$GeneratorStatus" | jq -rc '.info.status[]'); do

                    ValidatorAddress="$( echo "$Validator" | jq -r '.address' )"
                    ValidatorName="$( "$LiskCoreBinaryFullPath" endpoint:invoke pos_getValidator '{"address":"'"$ValidatorAddress"'"}' | jq -r '.name' )"
                    GeneratorEnabled="$( echo "$Validator" | jq -r '.enabled' )"

                    if [ "$GeneratorEnabled" = true ]
                    then
                        echo "$ValidatorName 'Generator Mode' is already ENABLED. ($ValidatorAddress)"
                    else

                        echo "Enabling 'Generator Mode' on $ValidatorName."

                        GeneratorHeight="$( echo "$Validator" | jq -r '.height' )"
                        GeneratorMaxHeightGenerated="$( echo "$Validator" | jq -r '.maxHeightGenerated' )"
                        GeneratorMaxHeightPrevoted="$( echo "$Validator" | jq -r '.maxHeightPrevoted' )"

                        if [ "$GeneratorHeight" -gt 0 ] && [ "$GeneratorMaxHeightGenerated" -gt 0 ] && [ "$GeneratorMaxHeightPrevoted" -gt 0 ]
                        then
                            if [ -z "$EncryptionPassword" ]
                            then
                                echo "CMD => generator:enable $ValidatorAddress --height=$GeneratorHeight --max-height-generated=$GeneratorMaxHeightGenerated --max-height-prevoted=$GeneratorMaxHeightPrevoted"

                                if [ "$Debug" = false ]
                                then
                                    "$LiskCoreBinaryFullPath" generator:enable "$ValidatorAddress" --height="$GeneratorHeight" --max-height-generated="$GeneratorMaxHeightGenerated" --max-height-prevoted="$GeneratorMaxHeightPrevoted"
                                else
                                    echo "DEBUG MODE is ON! Skipping 'lisk-core generator:enable' command execution."
                                fi
                            else
                                echo "CMD => generator:enable $ValidatorAddress --height=$GeneratorHeight --max-height-generated=$GeneratorMaxHeightGenerated --max-height-prevoted=$GeneratorMaxHeightPrevoted --password ***************"

                                if [ "$Debug" = false ]
                                then
                                    "$LiskCoreBinaryFullPath" generator:enable "$ValidatorAddress" --height="$GeneratorHeight" --max-height-generated="$GeneratorMaxHeightGenerated" --max-height-prevoted="$GeneratorMaxHeightPrevoted" --password "$EncryptionPassword"
                                else
                                    echo "DEBUG MODE is ON! Skipping 'lisk-core generator:enable' command execution."
                                fi
                            fi
                        else
                            echo "Warning: (POM Protection) The current values countain a 0 value at least for one parameter."
                            echo ''
                            echo "You should use '0 0 0' ONLY IF you enable 'Generator Mode' for a Validator that never created any block."
                            echo ''
                            echo "If it's the case, manually run:"
                            echo "lisk-core generator:enable $ValidatorAddress --height=0 --max-height-generated=0 --max-height-prevoted=0"
                            echo ''
                            echo "If it's NOT the case, the local values are empty and/or invalid. Try to find what happen & the correct values before re-enabling 'Generator Mode'."
                            echo "Good luck :)"
                        fi
                    fi
                done
                exit 0
            else
                echo "Warning : Node is currently in pre-syncing. Retrying in $RetryDelay second(s)..."
            fi
        else
            echo "Warning : Node is currently syncing. Retrying in $RetryDelay second(s)..."
        fi

        echo "          CurrentTry: $CurrentTry | MaxRetry: $MaxRetry | Current Height: $NodeHeight | Top Height: $TopHeight"
        sleep "$RetryDelay"
        CurrentTry=$((CurrentTry+1))

    fi
done

echo "Error: Node still syncing after $MaxRetry retry. Aborting..." >&2
exit 1
