// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "./ERC4626.sol";

/**
 * @title ERC4626Testable
 * @dev Testable version of ERC4626 exposing helper functions for testing
 * @notice DO NOT use this in production - use ERC4626 instead
 */
contract ERC4626Testable is ERC4626 {
    constructor(address asset_, string memory name_, string memory symbol_) ERC4626(asset_, name_, symbol_) {}
}
