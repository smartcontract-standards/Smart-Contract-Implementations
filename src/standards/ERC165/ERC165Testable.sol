// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC165} from "./ERC165.sol";

/**
 * @title ERC165Testable
 * @dev Testable ERC165 implementation that exposes _registerInterface for testing
 * @notice DO NOT use in production - use ERC165 as base and call _registerInterface in constructor
 */
contract ERC165Testable is ERC165 {
    /// @dev Custom interface for testing (e.g. bytes4(keccak256("foo()")))
    bytes4 public constant FOO_INTERFACE = 0x00000001;

    constructor() {
        _registerInterface(FOO_INTERFACE);
    }

    function foo() external pure returns (uint256) {
        return 42;
    }
}
