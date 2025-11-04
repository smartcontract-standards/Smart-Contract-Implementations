// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721} from "../src/standards/ERC721/ERC721.sol";

/**
 * @title ERC721Deploy
 * @dev Deployment script for ERC721 token
 */
contract ERC721Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Token parameters - modify these as needed
        string memory name = "My NFT";
        string memory symbol = "MNFT";
        string memory baseURI = "https://api.example.com/token/";

        vm.startBroadcast(deployerPrivateKey);

        ERC721 token = new ERC721(name, symbol, baseURI);

        vm.stopBroadcast();

        console.log("Token deployed at:", address(token));
        console.log("Token name:", name);
        console.log("Token symbol:", symbol);
        console.log("Base URI:", baseURI);
    }
}
