# Pandora Smart Contracts

Core set of Ethereum contracts for Pandora Boxchain implementing the first level of consensus. 
For details on the first level of consensus please check 
["3.3. Proof of Cognitive Work (PoCW)" in Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)

## Implementation Details

Contracts implement [Pandora Protocol Specification](https://github.com/pandoraboxchain/techspecs/wiki)

Current version is a limited implementation and is subjected for further development. We are working on the first
cognitive network implementation codenamed "Pyrrha", after the first Pandora daughter.

Core contract is [`Pandora.sol`](contracts/Pandora.sol), you can look through its [code](contracts/Pandora.sol).

## Usage

To initialize a project with this exapmple, run `truffle init webpack` inside an empty directory.

## Building and the frontend

1. First run `truffle compile`, then run `truffle migrate` to deploy the contracts onto your network of choice (default "development").
1. Then run `npm run dev` to build the app and serve it on http://localhost:8080

## Possible upgrades

* Use the webpack hotloader to sense when contracts or javascript have been recompiled and rebuild the application. Contributions welcome!

## Common Errors

* `Error: Can't resolve '../build/contracts/MetaCoin.json'`

This means you haven't compiled or migrated your contracts yet. Run `truffle compile` and `truffle migrate` first.

Full error:

```
ERROR in ./app/main.js
Module not found: Error: Can't resolve '../build/contracts/MetaCoin.json' in '/Users/tim/Documents/workspace/Consensys/test3/app'
 @ ./app/main.js 11:16-59
```
