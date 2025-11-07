# ERC4626 Implementation

A comprehensive implementation of the ERC-4626 Tokenized Vault Standard following EIP-4626.

## 📋 Overview

This implementation provides a fully compliant ERC4626 vault for tokenized deposits of an underlying ERC20 asset:

- **Tokenized Shares**: Issues ERC20-compliant shares representing vault deposits
- **Accurate Accounting**: Tracks total assets and supports conversions between assets and shares
- **Standard Interface**: Implements the full ERC-4626 interface for integrators
- **Operator Support**: Standard share transfers and allowances via ERC20 interface
- **Gas Optimized**: Uses `unchecked` blocks where safe and minimal storage reads

## 📁 Files

- **ERC4626.sol**: Main production ERC4626 implementation
- **ERC4626Testable.sol**: Testable version for exposing internal logic
- **Test**: Comprehensive test suite covering all functionality

## 🚀 Usage

### Deployment

Deploy using the included script:

```bash
forge script script/ERC4626Deploy.s.sol:ERC4626Deploy --rpc-url <RPC_URL> --private-key <KEY> --broadcast
```

Or deploy directly:

```solidity
import {ERC4626} from "src/standards/ERC4626/ERC4626.sol";

ERC4626 vault = new ERC4626(
    address(assetToken),  // Underlying ERC20 asset
    "Vault Share",        // Vault share name
    "vAsset"              // Vault share symbol
);
```

### Core Functions

```solidity
// Deposit assets, receive shares
uint256 shares = vault.deposit(assets, receiver);

// Mint shares, transferring required assets from caller
uint256 assets = vault.mint(shares, receiver);

// Withdraw assets, burning shares from owner
uint256 sharesBurned = vault.withdraw(assets, receiver, owner);

// Redeem shares directly
uint256 assetsReturned = vault.redeem(shares, receiver, owner);

// Conversion helpers
uint256 sharesOut = vault.convertToShares(assets);
uint256 assetsOut = vault.convertToAssets(shares);

// Preview helpers (read-only)
vault.previewDeposit(assets);
vault.previewMint(shares);
vault.previewWithdraw(assets);
vault.previewRedeem(shares);
```

## ✅ Test Coverage

The implementation includes a comprehensive Foundry test suite:

### Deposit & Mint
- ✅ Successful deposits and mints
- ✅ Event emission checks
- ✅ Reverts on invalid inputs

### Withdraw & Redeem
- ✅ Owner withdrawals
- ✅ Operator approvals
- ✅ Reverts on insufficient allowance
- ✅ Reverts on zero values

### Preview & Conversion
- ✅ Preview functions match conversions
- ✅ Rounding up/down behaviour validated
- ✅ Yield accrual scenarios

### ERC20 Compatibility
- ✅ Transfers and allowances
- ✅ Metadata checks (name, symbol, decimals)

### Edge Cases
- ✅ Vault with accrued yield
- ✅ Max functions (deposit, mint, withdraw, redeem)

## 🔒 Security Considerations

- ✅ Zero address checks on mint/burn/transfer
- ✅ Allowance management mirroring ERC20 best practices
- ✅ Balance checks to avoid underflows
- ✅ Asset transfer success checks
- ⚠️ No access control or fees — add before production use

## 📊 Gas Optimization

- **Unchecked arithmetic** where safe
- **Minimal storage reads** by caching balances where possible
- **Rounded conversions** using helper functions for predictable behaviour

## 🧪 Running Tests

```bash
forge test --match-path test/standards/ERC4626/ERC4626.t.sol
forge test --match-path test/standards/ERC4626/ERC4626.t.sol -vv
forge test --match-path test/standards/ERC4626/ERC4626.t.sol --gas-report
```

## 📚 Resources

- [EIP-4626 Specification](https://eips.ethereum.org/EIPS/eip-4626)
- [Foundry Documentation](https://book.getfoundry.sh/)

## ⚠️ Disclaimer

**DO NOT deploy to mainnet without a comprehensive security audit.** This code is provided for educational and reference purposes only.

## 📝 Notes

- Shares follow ERC20 semantics with standard approvals and transfers
- Decimals match the underlying asset
- No fees or hooks are implemented — extend `_before`/`_after` patterns as needed
- Override `totalAssets()` if assets generate yield outside of token balance accounting
