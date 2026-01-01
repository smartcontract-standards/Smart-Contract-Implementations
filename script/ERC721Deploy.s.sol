// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721} from "../src/standards/ERC721/ERC721.sol";

/**
 * @title ERC721Deploy
 * @dev Deployment script for ERC721 NFT contract
 */
contract ERC721Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // NFT parameters - modify these as needed
        string memory name = "My NFT Collection";
        string memory symbol = "MNFT";

        vm.startBroadcast(deployerPrivateKey);

        ERC721 nft = new ERC721(name, symbol);

        vm.stopBroadcast();

        console.log("NFT contract deployed at:", address(nft));
        console.log("Collection name:", name);
        console.log("Collection symbol:", symbol);
    }
}

