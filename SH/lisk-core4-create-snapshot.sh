#!/bin/bash -e

# Lisk-Core v4
# Gr33nDrag0n v1.0 (2023-05-28)

#---

# Can be edited

OUTPUT_DIRECTORY="$HOME/beta4-snapshot"
DAYS_TO_KEEP="3" # Use 0 to disable the feature

# Do not edit

OUTPUT_GZIP_FILENAME="blockchain.tar.gz"
OUTPUT_GZIP_FILEPATH="$OUTPUT_DIRECTORY/$OUTPUT_GZIP_FILENAME"
OUTPUT_HASH_FILEPATH="$OUTPUT_DIRECTORY/$OUTPUT_GZIP_FILENAME.SHA256"

### Function(s) #######################################################################################################

now() {
    date +'%Y-%m-%d %H:%M:%S'
}

### MAIN ##############################################################################################################

# Required for lisk-core command availability in crontab job.
export PATH="$PATH:$HOME/lisk-core/bin"

mkdir -p "$OUTPUT_DIRECTORY"

echo -e "$(now) Get Blockchain Height"

NODEINFO_JSON=$( lisk-core system:node-info )

if [ -z "$NODEINFO_JSON" ]; then
    echo  -e "$(now) ERROR: Node Info is invalid. Aborting..."
    exit 1
fi

HEIGHT=$( echo "$NODEINFO_JSON" | jq '.height' )
echo -e "$(now) Blockchain Height: $HEIGHT"

echo -e "$(now) Create $OUTPUT_GZIP_FILENAME"
lisk-core blockchain:export --output "$OUTPUT_DIRECTORY"

echo -e "$(now) Create $OUTPUT_GZIP_FILENAME.SHA256"
cd "$OUTPUT_DIRECTORY" && sha256sum "$OUTPUT_GZIP_FILENAME" > "$OUTPUT_HASH_FILEPATH"

OUTPUT_GZIP_COPY_FILENAME="blockchain-$HEIGHT.tar.gz"
OUTPUT_GZIP_COPY_FILEPATH="$OUTPUT_DIRECTORY/$OUTPUT_GZIP_COPY_FILENAME"
OUTPUT_HASH_COPY_FILEPATH="$OUTPUT_DIRECTORY/$OUTPUT_GZIP_COPY_FILENAME.SHA256"

echo -e "$(now) Create $OUTPUT_GZIP_COPY_FILENAME"
cp "$OUTPUT_GZIP_FILEPATH" "$OUTPUT_GZIP_COPY_FILEPATH"

echo -e "$(now) Create $OUTPUT_GZIP_COPY_FILENAME.SHA256"
cd "$OUTPUT_DIRECTORY" && sha256sum "$OUTPUT_GZIP_COPY_FILENAME" > "$OUTPUT_HASH_COPY_FILEPATH"

echo -e "$(now) Update new files permissions"
chmod 644 "$OUTPUT_GZIP_FILEPATH"
chmod 644 "$OUTPUT_HASH_FILEPATH"
chmod 644 "$OUTPUT_GZIP_COPY_FILEPATH"
chmod 644 "$OUTPUT_HASH_COPY_FILEPATH"

if [ "$DAYS_TO_KEEP" -gt 0 ]; then
    echo -e "$(now) Deleting snapshots older then $DAYS_TO_KEEP day(s)"
    mkdir -p "$OUTPUT_DIRECTORY" &> /dev/null
    find "$OUTPUT_DIRECTORY" -name "blockchain-*.tar.gz*" -mtime +"$(( DAYS_TO_KEEP - 1 ))" -exec rm {} \;
fi

exit 0
