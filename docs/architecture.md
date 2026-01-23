# Architecture

## Components

1. Smart Contracts (Solidity)

- Campaign management (create, contribute, finalize)
- Reward ERC-20 token minting

2. Frontend (JavaScript)

- MetaMask connection
- Display wallet, network check
- Campaign UI (create/contribute)
- Balance UI (ETH + reward token)

## Data Flow

User -> MetaMask -> Frontend (ethers.js) -> Contracts (testnet)
