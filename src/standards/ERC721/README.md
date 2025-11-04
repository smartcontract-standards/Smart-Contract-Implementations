# ERC721 Implementation

A comprehensive, modular implementation of the ERC-721 Non-Fungible Token Standard following EIP-721.

## 📋 Overview

This implementation provides a fully compliant ERC721 token with all standard features:

- **Standard Functions**: `transferFrom`, `safeTransferFrom`, `approve`, `setApprovalForAll`, `balanceOf`, `ownerOf`, `getApproved`, `isApprovedForAll`
- **Metadata**: `name`, `symbol`, `tokenURI` as per EIP-721 extension
- **Internal Functions**: `_mint`, `_safeMint`, `_burn` for token lifecycle management
- **Events**: `Transfer`, `Approval`, and `ApprovalForAll` events as per standard
- **Gas Optimized**: Uses `unchecked` blocks where safe for gas efficiency

## 📁 Files

- **ERC721.sol**: Main production ERC721 implementation
- **ERC721Testable.sol**: Testable version exposing internal mint/burn functions
- **Test**: Comprehensive test suite covering all functionality

## 🚀 Usage

### Deployment

Deploy using the included script:

```bash
forge script script/ERC721Deploy.s.sol:ERC721Deploy --rpc-url <RPC_URL> --private-key <KEY> --broadcast
```

Or deploy directly:

```solidity
import {ERC721} from "src/standards/ERC721/ERC721.sol";

ERC721 token = new ERC721(
    "My NFT",                           // name
    "MNFT",                             // symbol
    "https://api.example.com/token/"    // baseURI
);
```

### Basic Operations

```solidity
// Mint a token (internal function, implement in your contract)
_mint(to, tokenId);

// Transfer a token
token.transferFrom(from, to, tokenId);

// Safe transfer (checks if recipient can handle NFTs)
token.safeTransferFrom(from, to, tokenId);

// Approve an address to transfer a specific token
token.approve(approved, tokenId);

// Approve an operator to manage all tokens
token.setApprovalForAll(operator, true);

// Check token owner
address owner = token.ownerOf(tokenId);

// Check balance
uint256 balance = token.balanceOf(address);

// Get approved address for a token
address approved = token.getApproved(tokenId);

// Check if operator is approved for all
bool approved = token.isApprovedForAll(owner, operator);

// Get token URI
string memory uri = token.tokenURI(tokenId);
```

## ✅ Test Coverage

The implementation includes comprehensive test coverage:

### Constructor Tests
- ✅ Sets correct metadata (name, symbol)
- ✅ Sets base URI correctly

### Mint Tests
- ✅ Successful mint
- ✅ Emits Transfer event
- ✅ Reverts when minting to zero address
- ✅ Reverts when token already minted
- ✅ Supports multiple token mints

### SafeMint Tests
- ✅ Successful safe mint
- ✅ Works with contract recipients

### Burn Tests
- ✅ Successful burn
- ✅ Emits Transfer event
- ✅ Reverts when token doesn't exist
- ✅ Clears approval on burn

### Transfer Tests
- ✅ Successful transfer
- ✅ Emits Transfer event
- ✅ Reverts when not owner/approved
- ✅ Reverts when transferring to zero address
- ✅ Reverts when from incorrect owner
- ✅ Clears approval on transfer

### SafeTransferFrom Tests
- ✅ Successful safe transfer
- ✅ Works with contract recipients

### Approve Tests
- ✅ Successful approval
- ✅ Emits Approval event
- ✅ Reverts when not owner/operator
- ✅ Reverts when approving to owner
- ✅ Works with operator approval
- ✅ Can approve zero address to clear

### GetApproved Tests
- ✅ Returns zero for non-existent token
- ✅ Returns zero by default

### SetApprovalForAll Tests
- ✅ Successful operator approval
- ✅ Emits ApprovalForAll event
- ✅ Reverts when approving to self
- ✅ Can revoke operator approval

### IsApprovedForAll Tests
- ✅ Returns false by default

### OwnerOf Tests
- ✅ Reverts when token doesn't exist

### BalanceOf Tests
- ✅ Reverts when zero address
- ✅ Returns zero by default

### TokenURI Tests
- ✅ Returns correct URI
- ✅ Reverts when token doesn't exist

### Edge Case Tests
- ✅ Transfer with approval works
- ✅ Transfer with operator approval works
- ✅ Mint, burn, and mint again works

## 🔒 Security Features

- ✅ Input validation on all functions
- ✅ Zero address checks
- ✅ Owner/approval checks before operations
- ✅ Safe transfer checks for contract recipients
- ✅ Safe arithmetic with `unchecked` blocks where appropriate
- ✅ No known vulnerabilities

## 📊 Gas Optimization

The implementation uses several gas optimization techniques:

- **Unchecked arithmetic**: Used for increments/decrements where overflow/underflow is impossible
- **Efficient storage layout**: Optimized mapping structure
- **Minimal storage reads**: Cache values when used multiple times
- **Early returns**: Return values efficiently

## 🧪 Running Tests

```bash
# Run all ERC721 tests
forge test --match-path test/standards/ERC721/ERC721.t.sol

# Run with verbosity
forge test --match-path test/standards/ERC721/ERC721.t.sol -vv

# Run with gas report
forge test --match-path test/standards/ERC721/ERC721.t.sol --gas-report
```

## 📚 Resources

- [EIP-721 Specification](https://eips.ethereum.org/EIPS/eip-721)
- [Foundry Documentation](https://book.getfoundry.sh/)

## ⚠️ Disclaimer

**DO NOT deploy to mainnet without a comprehensive security audit.** This code is provided for educational and reference purposes only.

## 📝 Notes

- This is a base ERC721 implementation. For production use, you may want to extend it with:
  - Access control (e.g., onlyOwner for minting)
  - Maximum supply limits
  - Minting price mechanisms
  - Royalty support (EIP-2981)
  - Enumerable extension (EIP-721 enumerable)

