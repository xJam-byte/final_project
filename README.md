# Decentralized Crowdfunding DApp (Hardhat + Solidity + Vanilla JS)

A minimal decentralized crowdfunding application on Ethereum:
- users create campaigns,
- contributors send ETH,
- contributors receive reward ERC-20 tokens (CWD) as proof-of-contribution.

> Reward rate: **100 CWD per 1 ETH contributed** (demo tokenomics; no monetary value).

---

## Table of Contents
- [What’s inside](#whats-inside)
- [How it works](#how-it-works)
- [Repository layout](#repository-layout)
- [Quick start (local)](#quick-start-local)
- [Deploy (testnet)](#deploy-testnet)
- [Run the frontend](#run-the-frontend)
- [Troubleshooting](#troubleshooting)
- [Security & limitations](#security--limitations)

---

## What’s inside
### Smart contracts (Solidity)
- **Crowdfunding.sol** — campaign creation, contributions, finalization.
- **RewardToken.sol** — ERC-20 reward token (CWD), minted to contributors.

### Frontend (Vanilla JS + MetaMask)
A static website that connects to MetaMask and interacts with deployed contracts via ABI + contract addresses.

### Deployment (Hardhat)
A deployment script that:
1) deploys contracts,
2) links Crowdfunding ↔ RewardToken,
3) exports ABI + addresses for the frontend.

---

## How it works
### Core user flows
1) **Create a campaign**
   - user provides title, goal (ETH), duration
2) **Contribute ETH**
   - contract records the contribution
   - contributor receives reward tokens (CWD) based on contribution amount
3) **Finalize**
   - after the deadline, campaign can be finalized
   - ETH is transferred to the campaign creator (demo logic)

> Note: exact function names/struct fields are defined in the contracts. See `docs/SMART_CONTRACTS.md` for a clean description template.

---

## Repository layout
High-level structure:

- `contracts/` — Hardhat project (contracts + scripts)
- `frontend/` — static client (HTML/CSS/JS + exported ABI/addresses)
- `docs/` — architecture + defense notes
- `assets/` — images/screenshots (optional for README/demo)

Deployment script exports:
- `frontend/contract-address.json`
- `frontend/RewardToken.json`
- `frontend/Crowdfunding.json`

---

## Quick start (local)
### Prerequisites
- Node.js + npm
- MetaMask browser extension

### 1) Install dependencies
From repo root:
```bash
npm install
