![##Images_README_Header##](./PNG/Header.png)

Misc. stuff related to lisk-core v4 beta network.


- [Disclaimer](#disclaimer)
- [Links](#links)
  - [Lisk Blog](#lisk-blog)
  - [Lisk Documentation](#lisk-documentation)
  - [Wallets](#wallets)
  - [HowTo](#howto)
  - [Faucet](#faucet)
  - [Public API Endpoints](#public-api-endpoints)
    - [Lisk Core WS API](#lisk-core-ws-api)
    - [Lisk Core HTTP API](#lisk-core-http-api)
    - [Lisk Service API](#lisk-service-api)
  - [Explorer](#explorer)
  - [Snapshot](#snapshot)
  - [Scripts](#scripts)
    - [Bash / Server](#bash--server)
    - [NodeJS](#nodejs)
    - [PowerShell 7](#powershell-7)

# Disclaimer

Valid for Lisk-Core 4 Betanet 0 ONLY!

**For most questions, take the time to read official Lisk-Core & Lisk-SDK documentation! [Links below](#documentation)**

This project is based on my configuration.
It was created with a mix of existing guides, documentation reading & personal experience.

Thanks to all peoples in lisk community participating on lisk-core betanet.
In particular to **przemer** for his answers.
My experience on betanet won't be the same without your work.

# Links

## Lisk Blog

* [Launch of Betanet v6](https://lisk.com/blog/posts/launch-of-betanet-v6)

## Lisk Documentation

```
Please note that the following betanet specific information is not in the documentation:

* OS: Ubuntu 20
* Default Lisk-Core Port: TCP 7667
* Default Lisk-Core WS & HTTP API Port: TCP 7887
```

* [Lisk-Core v4](https://lisk.com/documentation/lisk-core/v4/index.html)
  * [Lisk-Core CLI](https://lisk.com/documentation/lisk-core/v4/core-cli.html)
  * [Lisk-Core API](https://lisk.com/documentation/beta/api/lisk-node-rpc.html)
* [Lisk-Service v0.7.0 API Documentation](https://github.com/LiskHQ/lisk-service/blob/v0.7.0-beta.1/docs/api/version3.md#lisk-service-api-documentation)
* [Running a blockchain node](https://lisk.com/documentation/beta/run-blockchain/index.html)
  * [Prepare and Enable your Validator](https://lisk.com/documentation/beta/run-blockchain/become-a-validator.html)
* [Lisk-SDK v6](https://lisk.com/documentation/lisk-sdk/v6/index.html)

## Wallets

* [Lisk Desktop v3.0.0-beta.0](https://github.com/LiskHQ/lisk-desktop/releases/tag/v3.0.0-beta.0)
* [Lisk Mobile v3.0.0-beta.0](https://github.com/LiskHQ/lisk-mobile/releases/tag/v3.0.0-beta.0)

## HowTo

* [Install Lisk-Core Beta4](./MD/InstallLiskCore.md)
* [Prepare a backup node for Validator/Generator](./MD/PrepareGeneratorBackupNode.md)
* [Switch Validator/Generator Active Node](./MD/SwitchGeneratorActiveNode.md)

## Faucet

*If the faucet is down, you can always ask in #network channel of lisk discord server.*

* [BetaNet v4 Faucet](https://betanet-faucet.lisk.com/)

## Public API Endpoints

### Lisk Core WS API

To quickly explore the API endpoint, you can use this online tool I've built: [https://beta4-wsexplorer.lisknode.io/](https://beta4-wsexplorer.lisknode.io/)

* gr33ndrag0n - [wss://beta4-api.lisknode.io/rpc-ws](wss://beta4-api.lisknode.io/rpc-ws)
* lemii - [wss://betanet-api.lemii.dev/rpc-ws](wss://betanet-api.lemii.dev/rpc-ws)

### Lisk Core HTTP API

* lisk - [https://betanet.lisk.com/rpc](https://betanet.lisk.com/rpc)
* gr33ndrag0n - [https://beta4-api.lisknode.io/rpc](https://beta4-api.lisknode.io/rpc)
* lemii - [https://betanet-api.lemii.dev/rpc](https://betanet-api.lemii.dev/rpc)

### Lisk Service API

* lisk - [https://betanet-service.lisk.com/](https://betanet-service.lisk.com)
* lemii - [https://betanet-service.lemii.dev/](https://betanet-service.lemii.dev)

## Explorer

* liskscan - [https://betanet.liskscan.com/](https://betanet.liskscan.com/)

## Snapshot

* gr33ndrag0n [beta4-snapshot.lisknode.io](https://beta4-snapshot.lisknode.io/)

## Scripts

### Bash / Server

* Generator
  * [lisk-core4-create-validator.sh](./SH/lisk-core4-create-validator.sh)
  * [lisk-core4-enable-generator.sh](./SH/lisk-core4-enable-generator.sh)
  * [lisk-core4-disable-generator.sh](./SH/lisk-core4-disable-generator.sh)
  * [lisk-core4-show-generator-info.sh](./SH/lisk-core4-show-generator-info.sh)
  * [lisk-core4-show-generator-import-cmd.sh](./SH/lisk-core4-show-generator-import-cmd.sh)

* Snapshot
  * [lisk-core4-create-snapshot.sh](./SH/lisk-core4-create-snapshot.sh)
  * [lisk-core4-rebuild-blockchain-from-snapshot.sh](./SH/lisk-core4-rebuild-blockchain-from-snapshot.sh)

### NodeJS

* liskscan - Lisk Service Client - [https://www.npmjs.com/package/@liskscan/lisk-service-client](https://www.npmjs.com/package/@liskscan/lisk-service-client)

### PowerShell 7

* [LWD4 - LiskWatchDog4](https://github.com/Gr33nDrag0n69/LWD4)
