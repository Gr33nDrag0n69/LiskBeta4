![##Header##](../PNG/Header.png)

Install Lisk-Core 4 Beta 0 on Ubuntu using binaries, PM2 & custom scripts

- [Install Base](#install-base)
- [Configure UFW firewall](#configure-ufw-firewall)
- [Install Lisk-Core Using Binary Method](#install-lisk-core-using-binary-method)
- [Install \& Configure PM2](#install--configure-pm2)
- [Create Bash Alias](#create-bash-alias)
- [Start Lisk](#start-lisk)
- [Create Account](#create-account)
- [Fund the account](#fund-the-account)
- [Wait for the lisk-core node to be sync.](#wait-for-the-lisk-core-node-to-be-sync)
- [Validate the Account have the required funds.](#validate-the-account-have-the-required-funds)
- [Create \& Enable Validator](#create--enable-validator)
- [Wait for Validator to generate a block as Generator](#wait-for-validator-to-generate-a-block-as-generator)
- [Download Forging Enable Script](#download-forging-enable-script)
- [Download Create Snapshot Script](#download-create-snapshot-script)
- [Download Rebuild From Snapshot Script](#download-rebuild-from-snapshot-script)

## Install Base

```shell
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get autoremove

sudo apt-get -y install wget tar zip unzip ufw npm git curl bash jq nodejs
```

## Configure UFW firewall

**Important:** To not get locked out of your server, make sure your management IP is static to use 'Allow From' command. If you are not sure of what to do, don't use 'Allow From' and just open port 22 (SSH) with `sudo ufw allow '22/tcp'`.

```shell
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Static Management IP
sudo ufw allow from "100.150.200.250/32"

# Lisk-Core
sudo ufw allow "7667/tcp"

sudo ufw --force enable
sudo ufw status
```

## Install Lisk-Core Using Binary Method

```shell
curl https://downloads.lisk.io/lisk/betanet/4.0.0-beta.1/lisk-core-v4.0.0-beta.1-linux-x64.tar.gz -o lisk-core.tar.gz
tar -xf ./lisk-core.tar.gz
rm -f ./lisk-core.tar.gz
echo 'export PATH="$PATH:$HOME/lisk-core/bin"' >> ~/.bashrc
source ~/.bashrc
```

## Install & Configure PM2

```shell
# Install NodeJS, NPM & PM2
sudo apt-get -y install nodejs npm
sudo npm i -g pm2

# Install PM2 Max Log Size Manager
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 100M

# Download lisk-core configuration files for PM2
curl https://raw.githubusercontent.com/Gr33nDrag0n69/LiskBeta4/main/PM2/lisk-core4.firststart.pm2.json -o ~/lisk-core4.pm2.json

```

## Create Bash Alias

```shell
cat > ~/.bash_aliases << EOF_Alias_Config
alias lisk-start='pm2 start ~/lisk-core4.pm2.json'
alias lisk-stop='pm2 stop lisk-core'
alias lisk-pm2logs='pm2 logs'
EOF_Alias_Config

source ~/.bashrc
```

## Start Lisk

```shell
lisk-start

# Validate the node is started & is syncing normally & proceed with the account creation process
lisk-pm2logs
```

## Create Account

Using [Lisk Desktop v3.0.0-beta.0](https://github.com/LiskHQ/lisk-desktop/releases/tag/v3.0.0-beta.0) create a new account.

## Fund the account

Using [BetaNet v4 Faucet](https://betanet-faucet.lisk.com/) or asking in `#network channel` of Lisk chat.

## Wait for the lisk-core node to be sync.

Run the following command until it return `false`

```shell
lisk-core endpoint:invoke system_getNodeInfo | jq '.syncing'
```

## Validate the Account have the required funds.

Output should be >= 101000000000 ( 10 LSK for registration & 1000 LSK for self-stake )

```shell
# Replace LSK address and run:
lisk-core endpoint:invoke token_getBalance '{"address":"lsk3oe7hmf5k5e4f58zhmbouzx3t4v98sgsfuhwnw", "tokenID":"0200000000000000"}' | jq '.availableBalance' |  tr -d '"'
```
## Create & Enable Validator

* Create/Register Validator
* Import Keys
* Generate HashOnion
* Enable block generation
* SelfStake to increase the validator weight

For some reasons the default config.json (or your custom-config) need to be edited to prevent a bug during keys import.

**After the config file is fixed, don't forget to stop/start the node to apply the new config file before proceeding with the next steps!**

```txt
vi ~/.lisk/lisk-core/config/config.json

# Replace this:
  "disabledMethods": ["generator","random"]

# By this
  "disabledMethods": []
```

If you want to understand the process, use the [Official Documentation](https://lisk.com/documentation/beta/run-blockchain/become-a-validator.html)

You can also use this script that bundle all steps into a single command.

```shell
curl https://raw.githubusercontent.com/Gr33nDrag0n69/LiskBeta4/main/SH/lisk-create-validator.sh -o ~/lisk-create-validator.sh
chmod 700 ~/lisk-create-validator.sh
~/lisk-create-validator.sh
```

Script tasks:

* 1.0 Nothing to do
* 2.1.1 Create the validator keys & save output to '~/config/ValidatorKeys.json'
* 2.1.2 Show '~/config/ValidatorKeys.json' content
* 2.2.1 Create the Register Validator transaction
* 2.2.2 Save Register Validator Transaction to '~/config/RegisterValidatorTransaction.json'
* 2.2.3 Show '~/config/RegisterValidatorTransaction.json'
* 2.3 Send the transaction
* Wait 25 seconds (For transaction to get included in a block)
* 2.4 Save validator details to '~/config/ValidatorDetails.json'
* 3.0 Import the validator keys
* 3.1.1 Save Generator Imported Keys to '~/config/GeneratorImportedKeys.json'
* 3.1.2 Show '~/config/GeneratorImportedKeys.json' content
* 4.0 Set the hash onion
* 4.1.1 Save hash onion seeds to '~/config/HashOnionSeeds.json'
* 4.1.2 Show '~/config/HashOnionSeeds.json' content
* 5.0 Nothing to do
* 6.0 Enable block generation for the first time (Using 0 0 0)
* 7.0 SelfStake to increase the validator weight
* 7.1.1 Create the SelfStake Transaction (1000 LSK SelfStake using 1 LSK for Fees)
* 7.1.2 Save SelfStake Transaction to '~/config/SelfStakeTransaction.json'
* 7.1.3 Show '~/config/SelfStakeTransaction.json'
* 7.2 Send the transaction
* Wait 25 seconds (For transaction to get included in a block)
* 7.3.1 Save SelfStake validator details to '~/config/SelfStakeValidatorDetails.json'
* 7.3.2 Show '~/config/SelfStakeValidatorDetails.json' content

## Wait for Validator to generate a block as Generator

*Since validators are selected 2 rounds ahead, it will take between 206 and 308 blocks after you voted yourself before your validator goes from standby to active.*

* Open the account in Lisk Wallet.
* Go to the validators section & search your validator name.
* You should have the `standby` status.
* Watch (after a while) that your status is `active` to confirm all went well.

## Download Forging Enable Script

```shell
#TODO
```

## Download Create Snapshot Script

```shell
#TODO
```

## Download Rebuild From Snapshot Script

```shell
#TODO
```
