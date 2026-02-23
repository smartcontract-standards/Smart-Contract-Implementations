// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC6909Testable} from "../../../src/standards/ERC6909/ERC6909Testable.sol";

contract ERC6909Test is Test {
    ERC6909Testable public token;

    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    event Transfer(address caller, address indexed sender, address indexed receiver, uint256 indexed id, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);
    event OperatorSet(address indexed owner, address indexed spender, bool approved);

    function setUp() public {
        vm.prank(owner);
        token = new ERC6909Testable();
    }

    // ===== Mint Tests =====

    function test_Mint_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount);

        assertEq(token.balanceOf(user1, id), amount, "User1 balance should match minted amount");
    }

    function test_Mint_EmitsTransferEvent() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        vm.expectEmit(false, true, true, true);
        emit Transfer(owner, address(0), user1, id, amount);
        
        token.mint(user1, id, amount);
    }

    // ===== Transfer Tests =====

    function test_Transfer_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount);
        
        vm.prank(user1);
        bool success = token.transfer(user2, id, 40);
        
        assertTrue(success, "Transfer should return true");
        assertEq(token.balanceOf(user1, id), 60, "User1 balance should decrease");
        assertEq(token.balanceOf(user2, id), 40, "User2 balance should increase");
    }

    function test_Transfer_EmitsTransferEvent() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount);
        
        vm.prank(user1);
        vm.expectEmit(false, true, true, true);
        emit Transfer(user1, user1, user2, id, 40);
        
        token.transfer(user2, id, 40);
    }

    function test_Transfer_RevertsWhenInsufficientBalance() public {
        uint256 id = 1;
        
        vm.prank(owner);
        token.mint(user1, id, 100);
        
        vm.prank(user1);
        vm.expectRevert("ERC6909: insufficient balance");
        token.transfer(user2, id, 101);
    }

    // ===== Approve Tests =====

    function test_Approve_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(user1);
        bool success = token.approve(user2, id, amount);
        
        assertTrue(success, "Approve should return true");
        assertEq(token.allowance(user1, user2, id), amount, "Allowance should be set");
    }

    // ===== Operator Tests =====

    function test_SetOperator_Success() public {
        vm.prank(user1);
        bool success = token.setOperator(user2, true);
        
        assertTrue(success, "SetOperator should return true");
        assertTrue(token.isOperator(user1, user2), "User2 should be operator for User1");
    }

    // ===== TransferFrom Tests =====

    function test_TransferFrom_WithAllowance_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount);
        
        vm.prank(user1);
        token.approve(user2, id, 40);
        
        vm.prank(user2);
        bool success = token.transferFrom(user1, user2, id, 40);
        
        assertTrue(success, "TransferFrom should return true");
        assertEq(token.balanceOf(user1, id), 60, "User1 balance should decrease");
        assertEq(token.balanceOf(user2, id), 40, "User2 balance should increase");
        assertEq(token.allowance(user1, user2, id), 0, "Allowance should be consumed");
    }

    function test_TransferFrom_WithOperator_Success() public {
        uint256 id = 1;
        uint256 amount = 100;
        
        vm.prank(owner);
        token.mint(user1, id, amount);
        
        vm.prank(user1);
        token.setOperator(user2, true);
        
        vm.prank(user2);
        bool success = token.transferFrom(user1, user2, id, 100);
        
        assertTrue(success, "TransferFrom should return true");
        assertEq(token.balanceOf(user1, id), 0, "User1 balance should decrease");
        assertEq(token.balanceOf(user2, id), 100, "User2 balance should increase");
    }

    function test_TransferFrom_RevertsWhenInsufficientAllowance() public {
        uint256 id = 1;
        
        vm.prank(owner);
        token.mint(user1, id, 100);
        
        vm.prank(user1);
        token.approve(user2, id, 40);
        
        vm.prank(user2);
        vm.expectRevert("ERC6909: insufficient allowance");
        token.transferFrom(user1, user2, id, 41);
    }
}
