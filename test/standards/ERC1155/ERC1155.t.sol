// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC1155Testable} from "../../../src/standards/ERC1155/ERC1155Testable.sol";
import {IERC1155Receiver} from "../../../src/shared/interfaces/IERC1155Receiver.sol";

contract ERC1155Test is Test {
    ERC1155Testable public token;

    string constant BASE_URI = "https://api.example.com/token/";

    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public operator = address(0x4);

    uint256 constant TOKEN_ID_1 = 1;
    uint256 constant TOKEN_ID_2 = 2;
    uint256 constant TOKEN_ID_3 = 3;
    uint256 constant AMOUNT_1 = 100;
    uint256 constant AMOUNT_2 = 200;

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function setUp() public {
        vm.prank(owner);
        token = new ERC1155Testable(BASE_URI);
    }

    // ===== Constructor Tests =====

    function test_Constructor_SetsBaseURI() public view {
        assertEq(token.uri(TOKEN_ID_1), string(abi.encodePacked(BASE_URI, "1")), "URI should match");
    }

    // ===== Mint Tests =====

    function test_Mint_Success() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        assertEq(token.balanceOf(user1, TOKEN_ID_1), AMOUNT_1, "Balance should match");
    }

    function test_Mint_EmitsTransferSingleEvent() public {
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(this), address(0), user1, TOKEN_ID_1, AMOUNT_1);

        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");
    }

    function test_Mint_RevertsWhenToZeroAddress() public {
        vm.expectRevert("ERC1155: mint to the zero address");
        token.mint(address(0), TOKEN_ID_1, AMOUNT_1, "");
    }

    function test_Mint_MultipleTokens() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");
        token.mint(user1, TOKEN_ID_2, AMOUNT_2, "");

        assertEq(token.balanceOf(user1, TOKEN_ID_1), AMOUNT_1, "Token 1 balance should match");
        assertEq(token.balanceOf(user1, TOKEN_ID_2), AMOUNT_2, "Token 2 balance should match");
    }

    // ===== MintBatch Tests =====

    function test_MintBatch_Success() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = TOKEN_ID_1;
        ids[1] = TOKEN_ID_2;
        amounts[0] = AMOUNT_1;
        amounts[1] = AMOUNT_2;

        token.mintBatch(user1, ids, amounts, "");

        assertEq(token.balanceOf(user1, TOKEN_ID_1), AMOUNT_1, "Token 1 balance should match");
        assertEq(token.balanceOf(user1, TOKEN_ID_2), AMOUNT_2, "Token 2 balance should match");
    }

    function test_MintBatch_EmitsTransferBatchEvent() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = TOKEN_ID_1;
        ids[1] = TOKEN_ID_2;
        amounts[0] = AMOUNT_1;
        amounts[1] = AMOUNT_2;

        vm.expectEmit(true, true, true, true);
        emit TransferBatch(address(this), address(0), user1, ids, amounts);

        token.mintBatch(user1, ids, amounts, "");
    }

    function test_MintBatch_RevertsWhenLengthMismatch() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = TOKEN_ID_1;
        ids[1] = TOKEN_ID_2;
        amounts[0] = AMOUNT_1;

        vm.expectRevert("ERC1155: ids and amounts length mismatch");
        token.mintBatch(user1, ids, amounts, "");
    }

    // ===== Burn Tests =====

    function test_Burn_Success() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");
        token.burn(user1, TOKEN_ID_1, 50);

        assertEq(token.balanceOf(user1, TOKEN_ID_1), 50, "Balance should be reduced");
    }

    function test_Burn_EmitsTransferSingleEvent() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(this), user1, address(0), TOKEN_ID_1, 50);

        token.burn(user1, TOKEN_ID_1, 50);
    }

    function test_Burn_RevertsWhenAmountExceedsBalance() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.expectRevert("ERC1155: burn amount exceeds balance");
        token.burn(user1, TOKEN_ID_1, AMOUNT_1 + 1);
    }

    // ===== BalanceOf Tests =====

    function test_BalanceOf_ReturnsZeroByDefault() public view {
        assertEq(token.balanceOf(user1, TOKEN_ID_1), 0, "Balance should be 0");
    }

    function test_BalanceOf_RevertsWhenZeroAddress() public {
        vm.expectRevert("ERC1155: address zero is not a valid owner");
        token.balanceOf(address(0), TOKEN_ID_1);
    }

    // ===== BalanceOfBatch Tests =====

    function test_BalanceOfBatch_Success() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");
        token.mint(user1, TOKEN_ID_2, AMOUNT_2, "");

        address[] memory accounts = new address[](2);
        uint256[] memory ids = new uint256[](2);
        accounts[0] = user1;
        accounts[1] = user1;
        ids[0] = TOKEN_ID_1;
        ids[1] = TOKEN_ID_2;

        uint256[] memory balances = token.balanceOfBatch(accounts, ids);

        assertEq(balances[0], AMOUNT_1, "Token 1 balance should match");
        assertEq(balances[1], AMOUNT_2, "Token 2 balance should match");
    }

    function test_BalanceOfBatch_RevertsWhenLengthMismatch() public {
        address[] memory accounts = new address[](2);
        uint256[] memory ids = new uint256[](1);
        accounts[0] = user1;
        accounts[1] = user2;
        ids[0] = TOKEN_ID_1;

        vm.expectRevert("ERC1155: accounts and ids length mismatch");
        token.balanceOfBatch(accounts, ids);
    }

    // ===== SafeTransferFrom Tests =====

    function test_SafeTransferFrom_Success() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user1);
        token.safeTransferFrom(user1, user2, TOKEN_ID_1, 50, "");

        assertEq(token.balanceOf(user1, TOKEN_ID_1), 50, "User1 balance should decrease");
        assertEq(token.balanceOf(user2, TOKEN_ID_1), 50, "User2 balance should increase");
    }

    function test_SafeTransferFrom_EmitsTransferSingleEvent() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(user1, user1, user2, TOKEN_ID_1, 50);

        token.safeTransferFrom(user1, user2, TOKEN_ID_1, 50, "");
    }

    function test_SafeTransferFrom_RevertsWhenNotOwner() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user2);
        vm.expectRevert("ERC1155: caller is not token owner nor approved");
        token.safeTransferFrom(user1, user2, TOKEN_ID_1, 50, "");
    }

    function test_SafeTransferFrom_RevertsWhenInsufficientBalance() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user1);
        vm.expectRevert("ERC1155: insufficient balance for transfer");
        token.safeTransferFrom(user1, user2, TOKEN_ID_1, AMOUNT_1 + 1, "");
    }

    function test_SafeTransferFrom_RevertsWhenToZeroAddress() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user1);
        vm.expectRevert("ERC1155: transfer to the zero address");
        token.safeTransferFrom(user1, address(0), TOKEN_ID_1, 50, "");
    }

    function test_SafeTransferFrom_WithApproval_Success() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user1);
        token.setApprovalForAll(operator, true);

        vm.prank(operator);
        token.safeTransferFrom(user1, user2, TOKEN_ID_1, 50, "");

        assertEq(token.balanceOf(user2, TOKEN_ID_1), 50, "User2 should receive tokens");
    }

    // ===== SafeBatchTransferFrom Tests =====

    function test_SafeBatchTransferFrom_Success() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");
        token.mint(user1, TOKEN_ID_2, AMOUNT_2, "");

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = TOKEN_ID_1;
        ids[1] = TOKEN_ID_2;
        amounts[0] = 50;
        amounts[1] = 100;

        vm.prank(user1);
        token.safeBatchTransferFrom(user1, user2, ids, amounts, "");

        assertEq(token.balanceOf(user2, TOKEN_ID_1), 50, "User2 should have token 1");
        assertEq(token.balanceOf(user2, TOKEN_ID_2), 100, "User2 should have token 2");
    }

    function test_SafeBatchTransferFrom_RevertsWhenLengthMismatch() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = TOKEN_ID_1;
        ids[1] = TOKEN_ID_2;
        amounts[0] = 50;

        vm.prank(user1);
        vm.expectRevert("ERC1155: ids and amounts length mismatch");
        token.safeBatchTransferFrom(user1, user2, ids, amounts, "");
    }

    // ===== SetApprovalForAll Tests =====

    function test_SetApprovalForAll_Success() public {
        vm.prank(user1);
        token.setApprovalForAll(operator, true);

        assertTrue(token.isApprovedForAll(user1, operator), "Operator should be approved");
    }

    function test_SetApprovalForAll_EmitsEvent() public {
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit ApprovalForAll(user1, operator, true);

        token.setApprovalForAll(operator, true);
    }

    function test_SetApprovalForAll_RevertsWhenApprovingSelf() public {
        vm.prank(user1);
        vm.expectRevert("ERC1155: setting approval status for self");
        token.setApprovalForAll(user1, true);
    }

    function test_SetApprovalForAll_CanRevoke() public {
        vm.prank(user1);
        token.setApprovalForAll(operator, true);
        assertTrue(token.isApprovedForAll(user1, operator), "Should be approved");

        vm.prank(user1);
        token.setApprovalForAll(operator, false);
        assertFalse(token.isApprovedForAll(user1, operator), "Should not be approved");
    }

    // ===== IsApprovedForAll Tests =====

    function test_IsApprovedForAll_ReturnsFalseByDefault() public view {
        assertFalse(token.isApprovedForAll(user1, operator), "Should return false by default");
    }

    // ===== URI Tests =====

    function test_URI_ReturnsCorrectURI() public view {
        assertEq(token.uri(TOKEN_ID_1), string(abi.encodePacked(BASE_URI, "1")), "URI should match");
    }

    // ===== Edge Case Tests =====

    function test_TransferThenBurn() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");

        vm.prank(user1);
        token.safeTransferFrom(user1, user2, TOKEN_ID_1, 50, "");

        token.burn(user2, TOKEN_ID_1, 30);

        assertEq(token.balanceOf(user1, TOKEN_ID_1), 50, "User1 should have 50");
        assertEq(token.balanceOf(user2, TOKEN_ID_1), 20, "User2 should have 20");
    }

    function test_MultipleUsersMultipleTokens() public {
        token.mint(user1, TOKEN_ID_1, AMOUNT_1, "");
        token.mint(user1, TOKEN_ID_2, AMOUNT_2, "");
        token.mint(user2, TOKEN_ID_1, AMOUNT_1, "");
        token.mint(user2, TOKEN_ID_3, 300, "");

        assertEq(token.balanceOf(user1, TOKEN_ID_1), AMOUNT_1, "User1 token1 balance");
        assertEq(token.balanceOf(user1, TOKEN_ID_2), AMOUNT_2, "User1 token2 balance");
        assertEq(token.balanceOf(user2, TOKEN_ID_1), AMOUNT_1, "User2 token1 balance");
        assertEq(token.balanceOf(user2, TOKEN_ID_3), 300, "User2 token3 balance");
    }
}

// Helper contract for testing safe transfers
contract Receiver is IERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}
