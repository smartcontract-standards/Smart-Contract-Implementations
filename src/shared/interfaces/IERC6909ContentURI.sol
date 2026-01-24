// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6909} from "./IERC6909.sol";

/// @dev Optional extension of {IERC6909} that adds content URI functions.
interface IERC6909ContentURI is IERC6909 {
    /// @dev Returns URI for the contract.
    function contractURI() external view returns (string memory);

    /// @dev Returns the URI for the token of type `id`.
    function tokenURI(uint256 id) external view returns (string memory);
}
