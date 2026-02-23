// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC1155Testable} from "../../../src/standards/ERC1155/ERC1155Testable.sol";
import {IERC1155Receiver} from "../../../src/shared/interfaces/IERC1155Receiver.sol";

contract ERC1155Test is Test {
    ERC1155Testable public token;

    string constant TEST_URI = "https://example.com/api/item/{id}.json";
    
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function setUp() public {
        vm.prank(owner);
        token = new ERC1155Testable(TEST_URI);
    }

    // ===== Constructor Tests =====

    function test_Constructor_SetsCorrectURI() public view {
        assertEq(token.uri(0), TEST_URI, "URI should match");
        assertEq(token.uri(1), TEST_URI, "URI should match for any ID");
    }

    // ===== Mint Tests =====

    function test_Mint_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.startPrank(owner);
        token.mint(user1, id, amount, "");

        assertEq(token.balanceOf(user1, id), amount, "User1 balance should match minted amount");
    }

    function test_Mint_EmitsTransferSingleEvent() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(owner, address(0), user1, id, amount);
        
        token.mint(user1, id, amount, "");
    }

    function test_MintBatch_Success() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;
        
        vm.startPrank(owner);
        token.mintBatch(user1, ids, amounts, "");

        assertEq(token.balanceOf(user1, 1), 100, "User1 balance for id 1 should be 100");
        assertEq(token.balanceOf(user1, 2), 200, "User1 balance for id 2 should be 200");
    }

    function test_MintBatch_EmitsTransferBatchEvent() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;
        
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit TransferBatch(owner, address(0), user1, ids, amounts);
        
        token.mintBatch(user1, ids, amounts, "");
    }

    // ===== Transfer Tests =====

    function test_SafeTransferFrom_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount, "");
        
        vm.prank(user1);
        token.safeTransferFrom(user1, user2, id, 40, "");
        
        assertEq(token.balanceOf(user1, id), 60, "User1 balance should decrease");
        assertEq(token.balanceOf(user2, id), 40, "User2 balance should increase");
    }

    function test_SafeTransferFrom_EmitsTransferSingleEvent() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount, "");
        
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(user1, user1, user2, id, 40);
        
        token.safeTransferFrom(user1, user2, id, 40, "");
    }

    function test_SafeTransferFrom_RevertsWhenInsufficientBalance() public {
        uint256 id = 1;
        
        vm.prank(owner);
        token.mint(user1, id, 100, "");
        
        vm.prank(user1);
        vm.expectRevert("ERC1155: insufficient balance for transfer");
        token.safeTransferFrom(user1, user2, id, 101, "");
    }

    function test_SafeBatchTransferFrom_Success() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;
        
        vm.prank(owner);
        token.mintBatch(user1, ids, amounts, "");
        
        uint256[] memory transferAmounts = new uint256[](2);
        transferAmounts[0] = 40;
        transferAmounts[1] = 60;
        
        vm.prank(user1);
        token.safeBatchTransferFrom(user1, user2, ids, transferAmounts, "");
        
        assertEq(token.balanceOf(user1, 1), 60, "User1 id 1 balance should decrease");
        assertEq(token.balanceOf(user1, 2), 140, "User1 id 2 balance should decrease");
        assertEq(token.balanceOf(user2, 1), 40, "User2 id 1 balance should increase");
        assertEq(token.balanceOf(user2, 2), 60, "User2 id 2 balance should increase");
    }

    // ===== Approval Tests =====

    function test_SetApprovalForAll_Success() public {
        vm.prank(user1);
        token.setApprovalForAll(user2, true);
        
        assertTrue(token.isApprovedForAll(user1, user2), "User2 should be approved for User1");
    }

    function test_SetApprovalForAll_EmitsApprovalForAllEvent() public {
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(user1, user2, true);
        
        token.setApprovalForAll(user2, true);
    }

    function test_SafeTransferFrom_WithApproval_Success() public {
        uint256 id = 1;
        
        vm.prank(owner);
        token.mint(user1, id, 100, "");
        
        vm.prank(user1);
        token.setApprovalForAll(user2, true);
        
        vm.prank(user2);
        token.safeTransferFrom(user1, user2, id, 40, "");
        
        assertEq(token.balanceOf(user1, id), 60, "User1 balance should decrease");
        assertEq(token.balanceOf(user2, id), 40, "User2 balance should increase");
    }

    // ===== Burn Tests =====

    function test_Burn_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount, "");
        
        vm.prank(user1);
        token.burn(user1, id, 40);
        
        assertEq(token.balanceOf(user1, id), 60, "Balance should decrease after burn");
    }

    function test_Burn_EmitsTransferSingleEvent() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount, "");
        
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(user1, user1, address(0), id, 40);
        
        token.burn(user1, id, 40);
    }
}
