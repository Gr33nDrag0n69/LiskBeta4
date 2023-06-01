![##Header##](../PNG/Header.png)

# Prepare a backup node for Validator/Generator.

Once your 2nd server lisk-core node is functional and in sync with network.
These are the commands to quickly copy encrypted keys & hash onion seeds on the backup node.
Take note that even if the "Last Block Info" are also transferred, they will be invalid (on server 2) as soon as another block is generated on server 1.
The process to safely switch active server (after this procedure will be done) is available [here]().

## Get Required Files from **Server 1**

1. Export Generator Info.
```shell
lisk-core generator:export -o "$HOME/server1-generator-export.json"
lisk-core endpoint:invoke random_getHashOnionSeeds > "$HOME/server1-hashonionseeds-export.json"
```

2. Download files.

3. Delete files.
```shell
rm -f "$HOME/server1-generator-export.json"
rm -f "$HOME/server1-hashonionseeds-export.json"
```

## Configure **Server 2**

1. Upload files

2. Import Generator Info (Encrypted Keys & Last Block Info)
```shell
lisk-core generator:import -f "$HOME/server1-generator-export.json"
```

3. Import HashOnionSeeds

```shell
for JsonParams in $( cat "$HOME/server1-hashonionseeds-export.json" | jq -rc '.seeds[]'); do
    lisk-core endpoint:invoke random_setHashOnion "$JsonParams"
done
```

4. Delete file.
```shell
rm -f "$HOME/server1-generator-export.json"
rm -f "$HOME/server1-hashonionseeds-export.json"
```
