# FundMe — Solidity Smart Contract with Foundry

A decentralized ETH funding smart contract built with Solidity and Foundry. The project demonstrates oracle-based ETH/USD price conversion, minimum funding requirements, funder tracking, access control, and owner withdrawals.

## Features

- **ETH funding:** Accepts ETH through a payable function.
- **Minimum contribution:** Requires a contribution worth at least $5 using the configured price feed.
- **Price conversion:** Converts ETH amounts into USD-denominated values using a Chainlink-compatible price feed.
- **Funder tracking:** Records contributions and tracks each funder once.
- **Access control:** Restricts withdrawals to the contract owner.
- **Safe withdrawal flow:** Resets contribution records and transfers the contract's ETH balance to the owner.
- **Automated tests:** Includes unit tests, revert tests, mock price feeds, and Foundry cheatcodes.

## Tech Stack

- Solidity
- Foundry: Forge, Cast, and Anvil
- Chainlink-compatible price feed interface
- Solidity unit testing and mocks

## Project Structure

```text
foundry-fund-me/
├── src/
│   ├── FundMe.sol
│   ├── interfaces/
│   │   └── AggregatorV3Interface.sol
│   └── price/
│       └── PriceConverter.sol
├── test/
│   ├── FundMe.t.sol
│   ├── PriceConverter.t.sol
│   └── mocks/
│       └── MockV3Aggregator.sol
├── script/
├── foundry.toml
└── README.md
```

## Getting Started

Install Foundry by following the official guide: https://getfoundry.sh/

Clone the repository and install its dependencies:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd foundry-fund-me
forge install
```

Build the contracts:

```bash
forge build
```

Run the test suite:

```bash
forge test -vv
```

Format the Solidity code:

```bash
forge fmt
```

## Testing Results

The project passed **19 automated tests with 0 failures** in the development environment.

- FundMe: 13 tests passed
- PriceConverter: 4 tests passed
- Counter: 2 tests passed

The test suite covers funding, minimum contribution validation, funder tracking, price conversion, stale price-feed rejection, access control, withdrawals, and failed ETH transfers.

## Local Deployment

The contracts were deployed and interacted with on a local Anvil blockchain during development. A mock price feed was configured to simulate an ETH price of $2,000.

The local deployment is for development and testing. It is not a public testnet or mainnet deployment.

## Security Notes

This is an educational project, not an audited production protocol. Before production use, review oracle configuration and freshness requirements, withdrawal gas costs, access control, and other smart contract security considerations.

## Author

Avinash Kumar

GitHub: https://github.com/Avikr11