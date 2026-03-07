# ERC-3156 Flash Loans

## Overview

Implementation of the [ERC-3156 Flash Loan Standard](https://eips.ethereum.org/EIPS/eip-3156). Enables uncollateralized lending within a single transaction with the condition that borrowed tokens are returned before the transaction ends.

## Features

- **Single-Asset Flash Loans**: Lend ERC20 tokens with callback pattern
- **Configurable Fee**: Fee in basis points (e.g., 9 = 0.09%)
- **Standard Interface**: Compatible with Aave, Uniswap, and other flash lenders

## Contracts

- `FlashLender.sol`: ERC-3156 compliant lender for a single ERC20 token
- `FlashBorrower.sol`: Example receiver for testing (approves repayment)

## Usage

### Deploy Lender

```solidity
// 0.09% fee (9 basis points)
FlashLender lender = new FlashLender(tokenAddress, 9);
// Deposit tokens to enable loans
lender.deposit(1_000_000e18);
```

### Execute Flash Loan

```solidity
contract MyBorrower is IERC3156FlashBorrower {
    function onFlashLoan(address, address token, uint256 amount, uint256 fee, bytes calldata data)
        external returns (bytes32)
    {
        // 1. Use the tokens (arbitrage, liquidate, etc.)
        // 2. Approve lender to pull amount + fee
        IERC20(token).approve(msg.sender, amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
```

## Testing

```bash
forge test --match-path test/standards/ERC3156/ERC3156.t.sol
```
