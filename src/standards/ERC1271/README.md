# ERC-1271 Standard Signature Validation

## Overview

Implementation of the [ERC-1271 Standard Signature Validation Method](https://eips.ethereum.org/EIPS/eip-1271). Enables smart contracts to verify signatures on behalf of contract accounts (e.g., smart wallets, multisigs).

## Features

- **Contract Signatures**: Validates ECDSA signatures where the signer is the contract owner
- **Magic Value**: Returns `0x1626ba7e` for valid, `0xffffffff` for invalid
- **65-byte Format**: Standard (r, s, v) signature encoding

## Contracts

- `ERC1271Wallet.sol`: Simple implementation that validates signatures from a single owner address

## Usage

```solidity
import {ERC1271Wallet} from "./ERC1271Wallet.sol";

// Deploy with owner (EOA or another contract)
ERC1271Wallet wallet = new ERC1271Wallet(ownerAddress);

// Off-chain: owner signs hash with private key
// bytes32 hash = keccak256(abi.encodePacked(message));
// bytes memory signature = abi.encodePacked(r, s, v);

// On-chain: verify
bytes4 result = wallet.isValidSignature(hash, signature);
require(result == 0x1626ba7e, "Invalid signature");
```

## Testing

```bash
forge test --match-path test/standards/ERC1271/ERC1271.t.sol
```
