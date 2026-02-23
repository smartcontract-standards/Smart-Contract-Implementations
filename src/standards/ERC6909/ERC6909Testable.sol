// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC6909} from "./ERC6909.sol";

/**
 * @title ERC6909Testable
 * @dev Extension of ERC6909 that exposes internal functions for testing purposes
 */
contract ERC6909Testable is ERC6909 {
    function mint(address receiver, uint256 id, uint256 amount) public {
        _mint(receiver, id, amount);
    }

    function burn(address sender, uint256 id, uint256 amount) public {
        _burn(sender, id, amount);
    }
}
