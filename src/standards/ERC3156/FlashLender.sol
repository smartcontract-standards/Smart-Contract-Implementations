// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC3156FlashLender} from "../../shared/interfaces/IERC3156FlashLender.sol";
import {IERC3156FlashBorrower} from "../../shared/interfaces/IERC3156FlashBorrower.sol";

/**
 * @title FlashLender
 * @dev ERC-3156 compliant flash lender for a single ERC20 token
 * @notice Lends tokens from its balance, charges a configurable fee (basis points)
 * @custom:security-contact This contract should be audited before use in production
 */
contract FlashLender is IERC3156FlashLender {
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    IERC20 public immutable token;
    uint256 public feeBps; // basis points (10000 = 100%)

    constructor(address token_, uint256 feeBps_) {
        require(token_ != address(0), "FlashLender: token is zero");
        token = IERC20(token_);
        feeBps = feeBps_;
    }

    /**
     * @dev See {IERC3156FlashLender-maxFlashLoan}.
     */
    function maxFlashLoan(address token_) external view override returns (uint256) {
        if (token_ != address(token)) return 0;
        return token.balanceOf(address(this));
    }

    /**
     * @dev See {IERC3156FlashLender-flashFee}.
     */
    function flashFee(address token_, uint256 amount) external view override returns (uint256) {
        require(token_ == address(token), "FlashLender: unsupported token");
        return (amount * feeBps) / 10_000;
    }

    /**
     * @dev See {IERC3156FlashLender-flashLoan}.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token_,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(token_ == address(token), "FlashLender: unsupported token");
        require(amount > 0, "FlashLender: zero amount");

        uint256 fee = (amount * feeBps) / 10_000;
        uint256 amountOwed = amount + fee;

        require(token.balanceOf(address(this)) >= amount, "FlashLender: insufficient balance");

        // Transfer tokens to receiver
        require(token.transfer(address(receiver), amount), "FlashLender: transfer failed");

        // Callback
        bytes32 result = receiver.onFlashLoan(msg.sender, token_, amount, fee, data);
        require(result == CALLBACK_SUCCESS, "IERC3156: Callback failed");

        // Pull back principal + fee
        require(token.transferFrom(address(receiver), address(this), amountOwed), "FlashLender: repay failed");

        return true;
    }

    /**
     * @dev Deposit tokens to enable flash loans. Anyone can deposit.
     */
    function deposit(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "FlashLender: deposit failed");
    }
}
