#!/bin/bash

# Gr33nDrag0n v1.2.0 (2021-03-30)

ForgingStatus=$( lisk-core forging:status )

BinaryAddress=$( echo $ForgingStatus | jq '.[0] | .address' | tr -d '"' )

Height=$( echo $ForgingStatus | jq '.[0] | .height // 0' )
MaxHeightPreviouslyForged=$( echo $ForgingStatus | jq '.[0] | .maxHeightPreviouslyForged // 0' )
MaxHeightPrevoted=$( echo $ForgingStatus | jq '.[0] | .maxHeightPrevoted // 0' )

echo "Command: lisk-core forging:enable $BinaryAddress $Height $MaxHeightPreviouslyForged $MaxHeightPrevoted"

lisk-core forging:enable $BinaryAddress $Height $MaxHeightPreviouslyForged $MaxHeightPrevoted
