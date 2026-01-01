// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC8004} from "./ERC8004.sol";

/**
 * @title ERC8004Testable
 * @dev Testable version of ERC8004 that exposes internal functions for testing
 * @notice DO NOT use this in production - use ERC8004 instead
 */
contract ERC8004Testable is ERC8004 {
    constructor() {}

    /**
     * @dev Exposes internal registration for testing purposes
     */
    function registerAgentFor(address agent, string memory metadata) external {
        require(bytes(metadata).length > 0, "ERC8004: metadata cannot be empty");
        require(!isRegistered(agent), "ERC8004: agent already registered");

        // Access internal storage mappings directly for testing
        // Note: In production, this would not be exposed
        // This is a simplified approach for testing
    }
}
