# ERC1155 Implementation

A comprehensive, modular implementation of the ERC-1155 Multi Token Standard following EIP-1155.

## 📋 Overview

This implementation provides a fully compliant ERC1155 token that supports both fungible and non-fungible tokens in a single contract:

- **Multi Token Support**: Handle multiple token types (fungible and non-fungible) in one contract
- **Batch Operations**: Efficient batch transfers and queries
- **Metadata**: URI support for each token type
- **Safe Transfers**: Safe transfer functions that check recipient contracts
- **Operator Approvals**: Approve operators to manage all tokens
- **Gas Optimized**: Uses `unchecked` blocks where safe for gas efficiency

## 📁 Files

- **ERC1155.sol**: Main production ERC1155 implementation
- **ERC1155Testable.sol**: Testable version exposing internal mint/burn functions
- **Test**: Comprehensive test suite covering all functionality

## 🚀 Usage

### Deployment

Deploy using the included script:

```bash
forge script script/ERC1155Deploy.s.sol:ERC1155Deploy --rpc-url <RPC_URL> --private-key <KEY> --broadcast
```

Or deploy directly:

```solidity
import {ERC1155} from "src/standards/ERC1155/ERC1155.sol";

ERC1155 token = new ERC1155("https://api.example.com/token/");
```

### Basic Operations

```solidity
// Mint tokens (internal function, implement in your contract)
_mint(to, tokenId, amount, data);

// Mint multiple token types in batch
_mintBatch(to, ids, amounts, data);

// Transfer tokens
token.safeTransferFrom(from, to, tokenId, amount, data);

// Batch transfer
token.safeBatchTransferFrom(from, to, ids, amounts, data);

// Check balance
uint256 balance = token.balanceOf(account, tokenId);

// Check multiple balances
uint256[] memory balances = token.balanceOfBatch(accounts, ids);

// Approve operator
token.setApprovalForAll(operator, true);

// Check approval
bool approved = token.isApprovedForAll(account, operator);

// Get token URI
string memory uri = token.uri(tokenId);
```

## ✅ Test Coverage

The implementation includes comprehensive test coverage:

### Constructor Tests
- ✅ Sets base URI correctly

### Mint Tests
- ✅ Successful mint
- ✅ Emits TransferSingle event
- ✅ Reverts when minting to zero address
- ✅ Supports multiple token types

### MintBatch Tests
- ✅ Successful batch mint
- ✅ Emits TransferBatch event
- ✅ Reverts when length mismatch

### Burn Tests
- ✅ Successful burn
- ✅ Emits TransferSingle event
- ✅ Reverts when amount exceeds balance

### BalanceOf Tests
- ✅ Returns zero by default
- ✅ Reverts when zero address

### BalanceOfBatch Tests
- ✅ Returns correct balances
- ✅ Reverts when length mismatch

### SafeTransferFrom Tests
- ✅ Successful transfer
- ✅ Emits TransferSingle event
- ✅ Reverts when not owner/approved
- ✅ Reverts when insufficient balance
- ✅ Reverts when transferring to zero address
- ✅ Works with operator approval

### SafeBatchTransferFrom Tests
- ✅ Successful batch transfer
- ✅ Reverts when length mismatch

### SetApprovalForAll Tests
- ✅ Successful approval
- ✅ Emits ApprovalForAll event
- ✅ Reverts when approving self
- ✅ Can revoke approval

### IsApprovedForAll Tests
- ✅ Returns false by default

### URI Tests
- ✅ Returns correct URI

### Edge Case Tests
- ✅ Transfer then burn
- ✅ Multiple users with multiple tokens

## 🔒 Security Features

- ✅ Input validation on all functions
- ✅ Zero address checks
- ✅ Balance checks before transfers/burns
- ✅ Safe transfer checks for contract recipients
- ✅ Safe arithmetic with `unchecked` blocks where appropriate
- ✅ No known vulnerabilities

## 📊 Gas Optimization

The implementation uses several gas optimization techniques:

- **Unchecked arithmetic**: Used for increments/decrements where overflow/underflow is impossible
- **Efficient storage layout**: Optimized mapping structure
- **Batch operations**: Reduce gas costs for multiple operations
- **Minimal storage reads**: Cache values when used multiple times

## 🧪 Running Tests

```bash
# Run all ERC1155 tests
forge test --match-path test/standards/ERC1155/ERC1155.t.sol

# Run with verbosity
forge test --match-path test/standards/ERC1155/ERC1155.t.sol -vv

# Run with gas report
forge test --match-path test/standards/ERC1155/ERC1155.t.sol --gas-report
```

## 📚 Resources

- [EIP-1155 Specification](https://eips.ethereum.org/EIPS/eip-1155)
- [Foundry Documentation](https://book.getfoundry.sh/)

## ⚠️ Disclaimer

**DO NOT deploy to mainnet without a comprehensive security audit.** This code is provided for educational and reference purposes only.

## 📝 Notes

- This is a base ERC1155 implementation. For production use, you may want to extend it with:
  - Access control (e.g., onlyOwner for minting)
  - Maximum supply limits per token type
  - Minting price mechanisms
  - Royalty support (EIP-2981)
  - Enumerable extension for tracking token IDs
  - Pausable functionality

## 💡 Use Cases

ERC1155 is ideal for:
- **Gaming**: Items, weapons, collectibles with different quantities
- **Marketplaces**: Multiple token types in a single contract
- **Loyalty Programs**: Points and rewards with different values
- **Art Collections**: Limited edition prints with quantities
- **Tickets**: Event tickets with different tiers
