// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC20WithPermit} from "../src/standards/ERC2612/ERC20WithPermit.sol";

/**
 * @title ERC2612Deploy
 * @dev Deployment script for ERC20 token with EIP-2612 permit support
 */
contract ERC2612Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        string memory name = "Permit Token";
        string memory symbol = "PRM";
        uint8 decimals = 18;
        uint256 totalSupply = 1000000e18;

        vm.startBroadcast(deployerPrivateKey);

        ERC20WithPermit token = new ERC20WithPermit(name, symbol, decimals, totalSupply);

        vm.stopBroadcast();

        console.log("ERC20 with Permit deployed at:", address(token));
        console.log("Token name:", name);
        console.log("Token symbol:", symbol);
        console.log("Total supply:", totalSupply);
    }
}
