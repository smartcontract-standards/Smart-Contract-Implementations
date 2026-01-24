// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6909} from "./IERC6909.sol";

/// @dev Optional extension of {IERC6909} that adds a token supply function.
interface IERC6909TokenSupply is IERC6909 {
    /// @dev Returns the total supply of the token of type `id`.
    function totalSupply(uint256 id) external view returns (uint256);
}
