# ERC-2612 Permit Extension for EIP-20

## Overview

This directory contains an implementation of the [ERC-2612 Permit Extension](https://eips.ethereum.org/EIPS/eip-2612), which adds gasless approval support to ERC-20 tokens via EIP-712 signed messages.

## Features

- **Gasless Approvals**: Users can approve token spending without sending a transaction
- **EIP-712 Signatures**: Structured data signing for wallet compatibility
- **Replay Protection**: Nonce-based protection against signature reuse
- **Deadline Support**: Optional expiration for signed permits

## Contracts

- `ERC20Permit.sol`: Abstract base that adds permit functionality to any ERC20
- `ERC20WithPermit.sol`: Concrete deployable ERC20 token with permit support
- `ERC20PermitTestable.sol`: Testable version that exposes mint/burn for testing

## Usage

### Deploying a token with permit

```solidity
import {ERC20WithPermit} from "./ERC20WithPermit.sol";

ERC20WithPermit token = new ERC20WithPermit(
    "My Token",
    "MTK",
    18,
    1000000e18
);
```

### Adding permit to an existing ERC20

Inherit from both your ERC20 and ERC20Permit:

```solidity
contract MyToken is MyERC20, ERC20Permit {
    constructor() ERC20Permit() {}
}
```

## Testing

```bash
forge test --match-path test/standards/ERC2612/ERC2612.t.sol
```
