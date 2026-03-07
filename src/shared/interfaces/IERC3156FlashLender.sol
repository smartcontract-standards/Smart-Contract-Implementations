// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC3156FlashBorrower} from "./IERC3156FlashBorrower.sol";

/**
 * @title IERC3156FlashLender
 * @dev Flash loan lender interface (EIP-3156)
 * @notice See https://eips.ethereum.org/EIPS/eip-3156
 */
interface IERC3156FlashLender {
    /**
     * @dev The amount of currency available to be lent
     * @param token The loan currency
     * @return The amount of `token` that can be borrowed
     */
    function maxFlashLoan(address token) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan
     * @param token The loan currency
     * @param amount The amount of tokens lent
     * @return The amount of `token` to be charged for the loan, on top of the returned principal
     */
    function flashFee(address token, uint256 amount) external view returns (uint256);

    /**
     * @dev Initiate a flash loan
     * @param receiver The receiver of the tokens and the callback
     * @param token The loan currency
     * @param amount The amount of tokens lent
     * @param data Arbitrary data structure
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}
