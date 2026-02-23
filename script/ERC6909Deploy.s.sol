// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC6909} from "../src/standards/ERC6909/ERC6909.sol";

/**
 * @title ERC6909Deploy
 * @dev Deployment script for ERC6909 token
 */
contract ERC6909Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ERC6909 token = new ERC6909();

        vm.stopBroadcast();

        console.log("ERC6909 Token deployed at:", address(token));
    }
}
