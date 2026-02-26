# ERC-2981 NFT Royalty Standard

## Overview

Implementation of the [ERC-2981 NFT Royalty Standard](https://eips.ethereum.org/EIPS/eip-2981), enabling universal royalty payments for NFTs across marketplaces.

## Features

- **Default Royalty**: Set a single receiver and fee (basis points) for all tokens
- **ERC721 & ERC1155**: Extensions for both NFT standards
- **EIP-165**: Interface detection for marketplace compatibility

## Contracts

- `ERC2981.sol`: Abstract base with royalty logic
- `ERC721WithRoyalty.sol`: ERC721 NFT with royalty support
- `ERC1155WithRoyalty.sol`: ERC1155 multi-token with royalty support
- `ERC721RoyaltyTestable.sol` / `ERC1155RoyaltyTestable.sol`: Testable versions

## Usage

### ERC721 with Royalty

```solidity
import {ERC721WithRoyalty} from "./ERC721WithRoyalty.sol";

// 7.5% royalty to deployer
ERC721WithRoyalty nft = new ERC721WithRoyalty(
    "My NFT",
    "MNFT",
    royaltyReceiver,
    750  // 7.5% in basis points (10000 = 100%)
);
```

### ERC1155 with Royalty

```solidity
import {ERC1155WithRoyalty} from "./ERC1155WithRoyalty.sol";

ERC1155WithRoyalty token = new ERC1155WithRoyalty(
    "https://api.example.com/{id}.json",
    royaltyReceiver,
    750  // 7.5%
);
```

## Testing

```bash
forge test --match-path test/standards/ERC2981/ERC2981.t.sol
```
