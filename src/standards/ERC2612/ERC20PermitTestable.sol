// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20WithPermit} from "./ERC20WithPermit.sol";

/**
 * @title ERC20PermitTestable
 * @dev Testable version of ERC20WithPermit that exposes internal functions
 * @notice DO NOT use this in production - use ERC20WithPermit instead
 */
contract ERC20PermitTestable is ERC20WithPermit {
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_)
        ERC20WithPermit(name_, symbol_, decimals_, totalSupply_)
    {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
