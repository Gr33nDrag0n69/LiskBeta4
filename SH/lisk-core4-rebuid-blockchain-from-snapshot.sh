#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.0 (2023-05-28)

PM2_CONFIG_FILE="$HOME/lisk-core4.pm2.json"
SNAPSHOT_URL="https://beta4-snapshot.lisknode.io/blockchain.tar.gz"

#--------------------------------------

lisk-core blockchain:download --url "$SNAPSHOT_URL" --output "$HOME/"
pm2 stop lisk-core4 --silent && sleep 3
lisk-core blockchain:import ~/blockchain.tar.gz --force
pm2 start "$PM2_CONFIG_FILE" --silent
rm -f ~/blockchain.tar.gz
rm -f ~/blockchain.tar.gz.SHA256
