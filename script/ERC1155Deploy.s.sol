// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC1155} from "../src/standards/ERC1155/ERC1155.sol";

/**
 * @title ERC1155Deploy
 * @dev Deployment script for ERC1155 Multi Token contract
 */
contract ERC1155Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Token parameters - modify these as needed
        string memory baseURI = "https://api.example.com/token/";

        vm.startBroadcast(deployerPrivateKey);

        ERC1155 token = new ERC1155(baseURI);

        vm.stopBroadcast();

        console.log("ERC1155 Token deployed at:", address(token));
        console.log("Base URI:", baseURI);
    }
}
