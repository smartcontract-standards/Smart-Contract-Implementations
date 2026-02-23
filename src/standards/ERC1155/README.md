# ERC1155 Multi Token Standard

## Overview

This directory contains a robust implementation of the ERC1155 Multi Token Standard. The implementation is designed to be secure, gas-efficient, and easy to extend.

## Features

- **Multi Token Standard**: Supports both fungible and non-fungible tokens in a single contract.
- **Batch Operations**: Allows for efficient batch transfers and balance queries.
- **Approval Mechanism**: Implements `setApprovalForAll` for operator approvals.
- **Metadata Support**: Includes metadata URI support with `{id}` substitution.
- **Safety Checks**: Ensures transfers to contracts implement `onERC1155Received`.

## Contracts

- `ERC1155.sol`: The core implementation of the ERC1155 standard.
- `ERC1155Testable.sol`: A testable version of the contract that exposes internal functions (mint/burn) for testing purposes.

## Usage

To use this contract, inherit from `ERC1155` and implement your specific logic.

```solidity
pragma solidity ^0.8.20;

import "./ERC1155.sol";

contract MyItems is ERC1155 {
    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, 1, 100, ""); // Mint 100 of item 1
        _mint(msg.sender, 2, 1, "");   // Mint 1 of item 2
    }
}
```

## Testing

Run the tests using Foundry:

```bash
forge test --match-path test/standards/ERC1155/ERC1155.t.sol
```
