// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC4626} from "../src/standards/ERC4626/ERC4626.sol";

/**
 * @title ERC4626Deploy
 * @dev Deployment script for ERC4626 vault
 */
contract ERC4626Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address asset = vm.envAddress("ERC4626_ASSET");
        string memory name = vm.envOr("ERC4626_NAME", string("Vault Share"));
        string memory symbol = vm.envOr("ERC4626_SYMBOL", string("vTOKEN"));

        vm.startBroadcast(deployerPrivateKey);

        ERC4626 vault = new ERC4626(asset, name, symbol);

        vm.stopBroadcast();

        console.log("ERC4626 vault deployed at:", address(vault));
        console.log("Underlying asset:", asset);
        console.log("Share name:", name);
        console.log("Share symbol:", symbol);
    }
}
