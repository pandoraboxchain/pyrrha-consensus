# Pandora Smart Contracts

Core set of Ethereum contracts for Pandora Boxchain implementing the first level of consensus. 
For details on the first level of consensus please check 
["3.3. Proof of Cognitive Work (PoCW)" in Pandora white paper](https://steemit.com/cryptocurrency/%40pandoraboxchain/world-decentralized-ai-on-blockchain-with-cognitive-mining-and-open-markets-for-data-and-algorithms-pandora-boxchain)

## Implementation Details
Contracts implement [Pandora Protocol Specification](https://github.com/pandoraboxchain/techspecs/wiki)

Current version is a limited implementation and is subjected for further development. We are working on the first
cognitive network implementation codenamed "Pyrrha", after the first Pandora daughter.

Core contract is [`Pandora.sol`](contracts/pandora/Pandora.sol), you can look through its [code](contracts/pandora/Pandora.sol).

## Deployment
Contract deployment is tested with local Ganache, Ethereum Testnets (Ropsten, Rinkeby) and RSK testnet.  

## Contracts documentation
Automatically generated documentation is placed in repository folder [./docs](https://github.com/pandoraboxchain/pyrrha-consensus/tree/master/docs)

## Known problems
### Deployment to the Ropsten network

Rinkeby and Ropsten testnets currently have different block gas limit: limit for Ropsten is lower then for Rinkeby (with the latter being nearly equivalent to the main net gas limit). Thus, while the core contracts can be published to the Ropsten network, there may by problems with calling Pandora.createWorker() method, since its gas consumption is near the upper bound of Ropsten block gas limit and the method will fail most of the time.

