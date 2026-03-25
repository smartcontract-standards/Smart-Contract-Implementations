# ERC-1363 Payable Token

## Overview

Implementation of the [ERC-1363 Payable Token](https://eips.ethereum.org/EIPS/eip-1363), which extends ERC-20 with callback-enabled transfers and approvals.

## Features

- **transferAndCall**: Transfer tokens and execute receiver logic in one transaction
- **transferFromAndCall**: Transfer on behalf of owner and invoke receiver callback
- **approveAndCall**: Approve spender and invoke spender callback
- **ERC-165 Detection**: Supports interface detection via `supportsInterface`

## Contracts

- `ERC1363.sol`: ERC1363 implementation extending `ERC20`
- `ERC1363Testable.sol`: Testable version exposing mint and burn

## Usage

```solidity
import {ERC1363} from "./ERC1363.sol";

ERC1363 token = new ERC1363("Payable Token", "PAY", 18, 1_000_000e18);
```

Receiver contracts must implement `IERC1363Receiver` and spender contracts must implement `IERC1363Spender`.

## Testing

```bash
forge test --match-path test/standards/ERC1363/ERC1363.t.sol
```
