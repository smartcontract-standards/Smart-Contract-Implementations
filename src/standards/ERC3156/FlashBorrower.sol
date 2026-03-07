// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC3156FlashBorrower} from "../../shared/interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "../../shared/interfaces/IERC3156FlashLender.sol";

/**
 * @title FlashBorrower
 * @dev Example ERC-3156 flash loan receiver for testing
 * @notice DO NOT use in production - implement your own logic in onFlashLoan
 */
contract FlashBorrower is IERC3156FlashBorrower {
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    function executeFlashLoan(
        IERC3156FlashLender lender,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        return lender.flashLoan(this, token, amount, data);
    }

    function onFlashLoan(
        address,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external override returns (bytes32) {
        // Must approve lender to pull amount + fee
        IERC20(token).approve(msg.sender, amount + fee);
        return CALLBACK_SUCCESS;
    }
}
