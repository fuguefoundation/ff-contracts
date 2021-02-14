![GitHub](https://img.shields.io/github/license/fuguefoundation/ff-contracts)

<p align="center">
  <img src="https://github.com/fuguefoundation/dapp-nonprofit/blob/master/src/assets/images/logo_150.png">
</p>

## About the Project

[Fugue Foundation](https://fuguefoundation.org) is a nonprofit dedicated to using open source, decentralized technology to achieve charitable goals rooted in the principles of effective altruism. Read this [blog post](https://blog.fuguefoundation.org/ff-platform-overiew/) to learn more about the use case and architecture of our flagship project, the Fugue Foundation decentralized application.

Ultimately these smart contracts will be incorporated into a decentralized application currently being developed in a [separate repo](https://github.com/fuguefoundation/ff-dapp).

<p align="center">
  <img src="https://github.com/fuguefoundation/ff-dapp/blob/master/src/assets/images/ff-dapp-flow.jpg">
</p>

## Setup

1. Install Truffle: `npm install -g truffle` - [Docs](https://www.trufflesuite.com/docs/truffle/quickstart)
2. Clone repo and run `npm install`
3. You will need to connect to a blockchain and Truffle provides different options, such as [Ganache](https://www.trufflesuite.com/docs/ganache/quickstart). **For development on a live testnet** (Goerli, Ropsten, etc.), create an `app.env` file to store private variables (see `truffle-config.js` file).
4. Run `truffle compile`, `truffle migrate` and `truffle test` to compile your contracts, deploy those contracts to the network, and run their associated unit tests. Truffle comes bundled with a local development blockchain server that launches automatically when you invoke the commands  above. You can interact with the contracts with `truffle console`.

## Contributing to the project

This is an open source project. Contributions are welcomed & encouraged! :smile: If you'd like to improve the code base, please see [Contributing Guidelines](CONTRIBUTE.md).

## Change Log

See [CHANGELOG](./CHANGELOG.md) for details.

## References
* [Kudos NFT](https://github.com/gitcoinco/Kudos721Contract)
* [Ethereum](https://ethereum.org/)
* [Truffle](http://truffleframework.com/docs/)
* [Open Zeppelin](https://docs.openzeppelin.com/openzeppelin/)
