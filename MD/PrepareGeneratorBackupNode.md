![##Header##](../PNG/Header.png)

# Prepare a backup node for Validator/Generator.

Once your 2nd server lisk-core node is functional and in sync with network.
Take note that even if the "Last Block Info" are also transferred, they will be invalid (on server 2) as soon as another block is generated on server 1.
To Switch Validator/Generator Active Node (after this procedure will be done) use the guide [here](./SwitchGeneratorActiveNode.md).

## Get Required Files from **Server 1**

1. Export ALL Validator(s) Keys, Generator(s) Info & Hash Onion Seeds
```shell
lisk-core keys:export -o "$HOME/server1-keys-export.json"
lisk-core generator:export -o "$HOME/server1-generator-export.json"
lisk-core endpoint:invoke random_getHashOnionSeeds > "$HOME/server1-hashonionseeds-export.json"
```

2. Show File Content & Inspect all look fine.
```shell
cat "$HOME/server1-keys-export.json"
cat "$HOME/server1-generator-export.json"
cat "$HOME/server1-hashonionseeds-export.json"
```

3. Download files.

4. Delete files.
```shell
rm -f "$HOME/server1-keys-export.json"
rm -f "$HOME/server1-generator-export.json"
rm -f "$HOME/server1-hashonionseeds-export.json"
```

## Edit Exported Files

If you have more then one Validator(s) Keys, Generator(s) Info or Hash Onion Seed configured in 'Server 1' and you don't want to import all of this data on 'Server 2', remove unwanted data from the json files.

## Configure **Server 2**

1. Upload exported files to HOME directory.

2. Import Validator(s) Keys

```shell
# Import
lisk-core keys:import --file-path "$HOME/server1-keys-export.json"
# Show
lisk-core endpoint:invoke generator_getAllKeys --pretty
```

3. Import HashOnionSeeds

**Note:**
If you get ` ›   Error: Response not received in 3000ms` message(s) during import, don't stress, it probably worked anyway.
Just go to next step.

```shell
# Import
for JsonParams in $( cat "$HOME/server1-hashonionseeds-export.json" | jq -rc '.seeds[]'); do
    lisk-core endpoint:invoke random_setHashOnion "$JsonParams"
done
# Show
lisk-core endpoint:invoke random_getHashOnionSeeds --pretty
```

4. Import Generator(s) Info
```shell
# Import
lisk-core generator:import -f "$HOME/server1-generator-export.json"
# Show
lisk-core generator:export
```

5. Delete file.
```shell
rm -f "$HOME/server1-keys-export.json"
rm -f "$HOME/server1-generator-export.json"
rm -f "$HOME/server1-hashonionseeds-export.json"
```

## Other Task(s)

* Delete the copy of the files on the computer you used to transfer them.

