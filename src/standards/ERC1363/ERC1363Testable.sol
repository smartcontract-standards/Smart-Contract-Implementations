// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1363} from "./ERC1363.sol";

/**
 * @title ERC1363Testable
 * @dev Testable version of ERC1363 with mint/burn helpers
 * @notice DO NOT use in production - use ERC1363 instead
 */
contract ERC1363Testable is ERC1363 {
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_)
        ERC1363(name_, symbol_, decimals_, totalSupply_)
    {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
