// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6909} from "./IERC6909.sol";

/// @dev Optional extension of {IERC6909} that adds metadata functions.
interface IERC6909Metadata is IERC6909 {
    /// @dev Returns the name of the token of type `id`.
    function name(uint256 id) external view returns (string memory);

    /// @dev Returns the ticker symbol of the token of type `id`.
    function symbol(uint256 id) external view returns (string memory);

    /// @dev Returns the number of decimals for the token of type `id`.
    function decimals(uint256 id) external view returns (uint8);
}
