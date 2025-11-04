// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC8004} from "../src/standards/ERC8004/ERC8004.sol";

/**
 * @title ERC8004Deploy
 * @dev Deployment script for ERC8004 Trustless Agents registry
 */
contract ERC8004Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ERC8004 registry = new ERC8004();

        vm.stopBroadcast();

        console.log("ERC8004 Registry deployed at:", address(registry));
        console.log("Registry ready for agent registration");
    }
}
