# ERC6909 Minimal Multi-Token Standard

## Overview

This directory contains an implementation of the [ERC-6909 Minimal Multi-Token Interface](https://eips.ethereum.org/EIPS/eip-6909). This standard provides a simplified alternative to ERC-1155, focusing on gas efficiency and ease of use.

## Features

- **Multi Token Standard**: Supports multiple token types in a single contract.
- **Gas Efficient**: Optimized storage layout and simplified logic.
- **Operator Approvals**: Supports both per-token approvals and "approval for all" operators.
- **Minimal Interface**: Removes some complexities of ERC-1155 like callbacks (by default) and batch operations (in the core interface).

## Contracts

- `ERC6909.sol`: The core implementation of the ERC6909 standard.
- `ERC6909Testable.sol`: A testable version that exposes internal mint/burn functions.

## Usage

Inherit from `ERC6909` to create your own multi-token contract:

```solidity
pragma solidity ^0.8.20;

import "./ERC6909.sol";

contract MyTokens is ERC6909 {
    constructor() {
        _mint(msg.sender, 1, 100); // Mint 100 of token ID 1
    }
}
```

## Testing

Run tests with Foundry:

```bash
forge test --match-path test/standards/ERC6909/ERC6909.t.sol
```
