// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../ERC20/ERC20.sol";
import {ERC20Permit} from "./ERC20Permit.sol";

/**
 * @title ERC20WithPermit
 * @dev Concrete ERC20 token with EIP-2612 permit support
 * @notice Deployable token that combines ERC20 with gasless approvals
 */
contract ERC20WithPermit is ERC20Permit {
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_)
        ERC20(name_, symbol_, decimals_, totalSupply_)
    {}
}
