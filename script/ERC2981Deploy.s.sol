// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721WithRoyalty} from "../src/standards/ERC2981/ERC721WithRoyalty.sol";

/**
 * @title ERC2981Deploy
 * @dev Deployment script for ERC721 NFT with royalty support
 */
contract ERC2981Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        string memory name = "Royalty NFT";
        string memory symbol = "RNFT";
        address royaltyReceiver = vm.addr(deployerPrivateKey);
        uint96 royaltyFeeNumerator = 750; // 7.5%

        vm.startBroadcast(deployerPrivateKey);

        ERC721WithRoyalty nft = new ERC721WithRoyalty(name, symbol, royaltyReceiver, royaltyFeeNumerator);

        vm.stopBroadcast();

        console.log("ERC721 with Royalty deployed at:", address(nft));
        console.log("Royalty receiver:", royaltyReceiver);
        console.log("Royalty fee (basis points):", royaltyFeeNumerator);
    }
}
