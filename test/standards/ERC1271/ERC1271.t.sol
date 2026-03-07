// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC1271Wallet} from "../../../src/standards/ERC1271/ERC1271Wallet.sol";
import {IERC1271} from "../../../src/shared/interfaces/IERC1271.sol";

contract ERC1271Test is Test {
    ERC1271Wallet public wallet;

    address public owner;
    uint256 public ownerKey;

    bytes32 public testHash;

    function setUp() public {
        (owner, ownerKey) = makeAddrAndKey("owner");
        wallet = new ERC1271Wallet(owner);
        testHash = keccak256("test message");
    }

    function test_IsValidSignature_ValidSignature() public {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, testHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes4 result = wallet.isValidSignature(testHash, signature);
        assertTrue(result == bytes4(0x1626ba7e));
    }

    function test_IsValidSignature_InvalidSigner() public {
        (, uint256 otherKey) = makeAddrAndKey("other");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(otherKey, testHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes4 result = wallet.isValidSignature(testHash, signature);
        assertTrue(result == bytes4(0xffffffff));
    }

    function test_IsValidSignature_WrongHash() public {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, testHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes32 wrongHash = keccak256("wrong message");
        bytes4 result = wallet.isValidSignature(wrongHash, signature);
        assertTrue(result == bytes4(0xffffffff));
    }

    function test_IsValidSignature_InvalidLength_Reverts() public {
        bytes memory shortSignature = abi.encodePacked(bytes32(0), bytes32(0));
        vm.expectRevert("ERC1271: invalid signature length");
        wallet.isValidSignature(testHash, shortSignature);
    }

    function test_Constructor_ZeroOwner_Reverts() public {
        vm.expectRevert("ERC1271: owner is zero");
        new ERC1271Wallet(address(0));
    }
}
