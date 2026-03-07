# ERC-165 Standard Interface Detection

## Overview

Implementation of the [ERC-165 Standard Interface Detection](https://eips.ethereum.org/EIPS/eip-165). Enables contracts to publish and detect what interfaces they implement.

## Features

- **Interface Registration**: Use `_registerInterface(bytes4)` in constructor to declare supported interfaces
- **Gas Efficient**: Mapping-based lookup (~586 gas per query)
- **Foundational**: Many other ERC standards (ERC721, ERC1155, etc.) depend on ERC-165

## Contracts

- `ERC165.sol`: Abstract base contract with `_registerInterface` and `supportsInterface`
- `ERC165Testable.sol`: Testable version for unit tests

## Usage

### As Base Contract

```solidity
import {ERC165} from "./ERC165.sol";

contract MyContract is ERC165, IMyInterface {
    constructor() {
        _registerInterface(type(IMyInterface).interfaceId);
    }

    // Implement IMyInterface...
}
```

### Interface ID Calculation

For a single function: `bytes4(keccak256("functionName(type)"))`
For multiple: XOR of all function selectors.

## Testing

```bash
forge test --match-path test/standards/ERC165/ERC165.t.sol
```
