// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC721Testable} from "../../../src/standards/ERC721/ERC721Testable.sol";
import {IERC721Receiver} from "../../../src/shared/interfaces/IERC721Receiver.sol";

contract ERC721Test is Test {
    ERC721Testable public token;

    string constant NAME = "Test NFT";
    string constant SYMBOL = "TNFT";
    string constant BASE_URI = "https://api.example.com/token/";

    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public operator = address(0x4);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setUp() public {
        vm.prank(owner);
        token = new ERC721Testable(NAME, SYMBOL);
        token = new ERC721Testable(NAME, SYMBOL, BASE_URI);
    }

    // ===== Constructor Tests =====

    function test_Constructor_SetsCorrectMetadata() public view {
        assertEq(token.name(), NAME, "Name should match");
        assertEq(token.symbol(), SYMBOL, "Symbol should match");
    }

    function test_Constructor_SetsBaseURI() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);
        assertEq(token.tokenURI(tokenId), string(abi.encodePacked(BASE_URI, "1")), "Token URI should match");
    }

    // ===== Mint Tests =====

    function test_Mint_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        assertEq(token.ownerOf(tokenId), user1, "User1 should own token");
        assertEq(token.balanceOf(user1), 1, "User1 balance should be 1");
        assertTrue(token.exists(tokenId), "Token should exist");
    }

    function test_Mint_EmitsTransferEvent() public {
        uint256 tokenId = 1;
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), user1, tokenId);

        token.mint(user1, tokenId);
    }

    function test_Mint_RevertsWhenToZeroAddress() public {
        vm.expectRevert("ERC721: mint to the zero address");
        token.mint(address(0), 1);
    }

    function test_Mint_RevertsWhenTokenAlreadyMinted() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.expectRevert("ERC721: token already minted");
        token.mint(user2, tokenId);
    }

    // ===== Transfer Tests =====

    function test_TransferFrom_Success() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        token.transferFrom(owner, user1, tokenId);

        assertEq(token.ownerOf(tokenId), user1, "User1 should own token");
        assertEq(token.balanceOf(owner), 0, "Owner balance should be 0");
        assertEq(token.balanceOf(user1), 1, "User1 balance should be 1");
    }

    function test_TransferFrom_EmitsTransferEvent() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, user1, tokenId);

        token.transferFrom(owner, user1, tokenId);
    }

    function test_TransferFrom_RevertsWhenNotOwner() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(user1);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        token.transferFrom(owner, user1, tokenId);
    }

    function test_TransferFrom_RevertsWhenToZeroAddress() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        vm.expectRevert("ERC721: transfer to the zero address");
        token.transferFrom(owner, address(0), tokenId);
    }

    // ===== SafeTransferFrom Tests =====

    function test_SafeTransferFrom_Success() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        token.safeTransferFrom(owner, user1, tokenId);

        assertEq(token.ownerOf(tokenId), user1, "User1 should own token");
    }

    function test_SafeTransferFrom_WithData() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        token.safeTransferFrom(owner, user1, tokenId, "0x1234");

        assertEq(token.ownerOf(tokenId), user1, "User1 should own token");
    }

    // ===== Approve Tests =====

    function test_Approve_Success() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        token.approve(user1, tokenId);

        assertEq(token.getApproved(tokenId), user1, "User1 should be approved");
    }

    function test_Approve_EmitsApprovalEvent() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit Approval(owner, user1, tokenId);

        token.approve(user1, tokenId);
    }

    function test_Approve_RevertsWhenNotOwner() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.prank(user1);
        vm.expectRevert("ERC721: approve caller is not token owner or approved for all");
        token.approve(user2, tokenId);
    }

    function test_Approve_AllowsApprovedOperator() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.startPrank(owner);
        token.setApprovalForAll(user1, true);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(user2, tokenId);

        assertEq(token.getApproved(tokenId), user2, "User2 should be approved");
    }

    // ===== SetApprovalForAll Tests =====

    function test_SetApprovalForAll_Success() public {
        vm.prank(owner);
        token.setApprovalForAll(user1, true);

        assertTrue(token.isApprovedForAll(owner, user1), "User1 should be approved for all");
    }

    function test_SetApprovalForAll_EmitsEvent() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit ApprovalForAll(owner, user1, true);

        token.setApprovalForAll(user1, true);
    }

    function test_SetApprovalForAll_CanRevoke() public {
        vm.startPrank(owner);
        token.setApprovalForAll(user1, true);
        assertTrue(token.isApprovedForAll(owner, user1), "Should be approved");

        token.setApprovalForAll(user1, false);
        assertFalse(token.isApprovedForAll(owner, user1), "Should not be approved");
        vm.stopPrank();
    }

    // ===== TransferFrom with Approval Tests =====

    function test_TransferFrom_WithApproval() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.startPrank(owner);
        token.approve(user1, tokenId);
        vm.stopPrank();

        vm.prank(user1);
        token.transferFrom(owner, user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
        assertEq(token.getApproved(tokenId), address(0), "Approval should be cleared");
    }

    function test_TransferFrom_WithOperatorApproval() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.startPrank(owner);
        token.setApprovalForAll(user1, true);
        vm.stopPrank();

        vm.prank(user1);
        token.transferFrom(owner, user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
    }

    // ===== Burn Tests =====

    function test_Burn_Success() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        token.burn(tokenId);

        assertFalse(token.exists(tokenId), "Token should not exist");
        assertEq(token.balanceOf(owner), 0, "Owner balance should be 0");
    }

    function test_Burn_EmitsTransferEvent() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, address(0), tokenId);

        token.burn(tokenId);
    }

    function test_Burn_ClearsApproval() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.startPrank(owner);
        token.approve(user1, tokenId);
        vm.stopPrank();

        token.burn(tokenId);

        vm.expectRevert("ERC721: invalid token ID");
        token.getApproved(tokenId);
    }

    // ===== BalanceOf Tests =====

    function test_BalanceOf_ReturnsCorrectly() public {
        assertEq(token.balanceOf(owner), 0, "Owner balance should be 0");

        token.mint(owner, 1);
        assertEq(token.balanceOf(owner), 1, "Owner balance should be 1");

        token.mint(owner, 2);
        assertEq(token.balanceOf(owner), 2, "Owner balance should be 2");
    }

    function test_BalanceOf_RevertsWhenZeroAddress() public {
        vm.expectRevert("ERC721: address zero is not a valid owner");
        token.balanceOf(address(0));
    }

    // ===== OwnerOf Tests =====

    function test_OwnerOf_ReturnsCorrectly() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        assertEq(token.ownerOf(tokenId), user1, "Owner should be user1");
    }

    function test_OwnerOf_RevertsWhenTokenDoesNotExist() public {
        vm.expectRevert("ERC721: invalid token ID");
        token.ownerOf(999);
    }

    // ===== Edge Cases =====

    function test_MultipleTokens_Success() public {
        token.mint(owner, 1);
        token.mint(owner, 2);
        token.mint(user1, 3);

        assertEq(token.balanceOf(owner), 2, "Owner should have 2 tokens");
        assertEq(token.balanceOf(user1), 1, "User1 should have 1 token");
        assertEq(token.ownerOf(1), owner, "Token 1 should belong to owner");
        assertEq(token.ownerOf(2), owner, "Token 2 should belong to owner");
        assertEq(token.ownerOf(3), user1, "Token 3 should belong to user1");
    }

    function test_TransferThenApprove() public {
        uint256 tokenId = 1;
        token.mint(owner, tokenId);

        vm.startPrank(owner);
        token.transferFrom(owner, user1, tokenId);
        vm.stopPrank();

        vm.prank(user1);
        token.approve(user2, tokenId);

        assertEq(token.getApproved(tokenId), user2, "User2 should be approved");
    }
}

contract Receiver is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract NonReceiver {}

contract ERC721ReceiverTest is Test {
    ERC721Testable public token;
    Receiver public receiver;
    NonReceiver public nonReceiver;

    function setUp() public {
        token = new ERC721Testable("Test", "T");
        receiver = new Receiver();
        nonReceiver = new NonReceiver();
    }

    function test_SafeMint_ToContractReceiver_Success() public {
        uint256 tokenId = 1;
        token.safeMint(address(receiver), tokenId);

        assertEq(token.ownerOf(tokenId), address(receiver), "Receiver should own token");
    }

    function test_SafeMint_ToEOA_Success() public {
        uint256 tokenId = 1;
        token.safeMint(address(0x1234), tokenId);

        assertEq(token.ownerOf(tokenId), address(0x1234), "EOA should own token");
    }

    function test_SafeMint_ToNonReceiver_Reverts() public {
        uint256 tokenId = 1;
        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        token.safeMint(address(nonReceiver), tokenId);
    }

    function test_SafeTransferFrom_ToReceiver_Success() public {
        uint256 tokenId = 1;
        token.mint(address(this), tokenId);

        token.safeTransferFrom(address(this), address(receiver), tokenId);

        assertEq(token.ownerOf(tokenId), address(receiver), "Receiver should own token");
    }

    function test_SafeTransferFrom_ToNonReceiver_Reverts() public {
        uint256 tokenId = 1;
        token.mint(address(this), tokenId);

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        token.safeTransferFrom(address(this), address(nonReceiver), tokenId);
    }
}

    function test_Mint_MultipleTokens() public {
        token.mint(user1, 1);
        token.mint(user1, 2);
        token.mint(user2, 3);

        assertEq(token.balanceOf(user1), 2, "User1 should have 2 tokens");
        assertEq(token.balanceOf(user2), 1, "User2 should have 1 token");
        assertEq(token.ownerOf(1), user1, "Token 1 should belong to user1");
        assertEq(token.ownerOf(2), user1, "Token 2 should belong to user1");
        assertEq(token.ownerOf(3), user2, "Token 3 should belong to user2");
    }

    // ===== SafeMint Tests =====

    function test_SafeMint_Success() public {
        uint256 tokenId = 1;
        token.safeMint(user1, tokenId);

        assertEq(token.ownerOf(tokenId), user1, "User1 should own token");
    }

    function test_SafeMint_ToContract_Success() public {
        Receiver receiver = new Receiver();
        uint256 tokenId = 1;
        token.safeMint(address(receiver), tokenId);

        assertEq(token.ownerOf(tokenId), address(receiver), "Receiver should own token");
    }

    // ===== Burn Tests =====

    function test_Burn_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);
        token.burn(tokenId);

        vm.expectRevert("ERC721: invalid token ID");
        token.ownerOf(tokenId);
        assertEq(token.balanceOf(user1), 0, "User1 balance should be 0");
    }

    function test_Burn_EmitsTransferEvent() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.expectEmit(true, true, true, true);
        emit Transfer(user1, address(0), tokenId);

        token.burn(tokenId);
    }

    function test_Burn_RevertsWhenTokenDoesNotExist() public {
        vm.expectRevert("ERC721: invalid token ID");
        token.burn(999);
    }

    function test_Burn_ClearsApproval() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.approve(user2, tokenId);
        assertEq(token.getApproved(tokenId), user2, "Token should be approved for user2");

        token.burn(tokenId);

        // Approval should be cleared after burn
        vm.expectRevert("ERC721: invalid token ID");
        token.getApproved(tokenId);
    }

    // ===== Transfer Tests =====

    function test_TransferFrom_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.transferFrom(user1, user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
        assertEq(token.balanceOf(user1), 0, "User1 balance should be 0");
        assertEq(token.balanceOf(user2), 1, "User2 balance should be 1");
    }

    function test_TransferFrom_EmitsTransferEvent() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit Transfer(user1, user2, tokenId);

        token.transferFrom(user1, user2, tokenId);
    }

    function test_TransferFrom_RevertsWhenNotOwner() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user2);
        vm.expectRevert("ERC721: caller is not token owner nor approved");
        token.transferFrom(user1, user2, tokenId);
    }

    function test_TransferFrom_RevertsWhenToZeroAddress() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        vm.expectRevert("ERC721: transfer to the zero address");
        token.transferFrom(user1, address(0), tokenId);
    }

    function test_TransferFrom_RevertsWhenFromIncorrectOwner() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        vm.expectRevert("ERC721: transfer from incorrect owner");
        token.transferFrom(user2, user1, tokenId);
    }

    function test_TransferFrom_ClearsApproval() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.approve(user2, tokenId);

        vm.prank(user2);
        token.transferFrom(user1, user2, tokenId);

        assertEq(token.getApproved(tokenId), address(0), "Approval should be cleared");
    }

    // ===== SafeTransferFrom Tests =====

    function test_SafeTransferFrom_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.safeTransferFrom(user1, user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
    }

    function test_SafeTransferFrom_ToContract_Success() public {
        Receiver receiver = new Receiver();
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.safeTransferFrom(user1, address(receiver), tokenId);

        assertEq(token.ownerOf(tokenId), address(receiver), "Receiver should own token");
    }

    // ===== Approve Tests =====

    function test_Approve_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.approve(user2, tokenId);

        assertEq(token.getApproved(tokenId), user2, "Token should be approved for user2");
    }

    function test_Approve_EmitsApprovalEvent() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit Approval(user1, user2, tokenId);

        token.approve(user2, tokenId);
    }

    function test_Approve_RevertsWhenNotOwner() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user2);
        vm.expectRevert("ERC721: approve caller is not owner nor approved for all");
        token.approve(user2, tokenId);
    }

    function test_Approve_RevertsWhenApprovingToOwner() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        vm.expectRevert("ERC721: approval to current owner");
        token.approve(user1, tokenId);
    }

    function test_Approve_ByOperator_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.setApprovalForAll(operator, true);

        vm.prank(operator);
        token.approve(user2, tokenId);

        assertEq(token.getApproved(tokenId), user2, "Token should be approved for user2");
    }

    function test_Approve_CanApproveZeroAddress() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.approve(user2, tokenId);

        vm.prank(user1);
        token.approve(address(0), tokenId);

        assertEq(token.getApproved(tokenId), address(0), "Approval should be cleared");
    }

    // ===== GetApproved Tests =====

    function test_GetApproved_ReturnsZeroForNonExistentToken() public {
        vm.expectRevert("ERC721: invalid token ID");
        token.getApproved(999);
    }

    function test_GetApproved_ReturnsZeroByDefault() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        assertEq(token.getApproved(tokenId), address(0), "Approval should default to zero");
    }

    // ===== SetApprovalForAll Tests =====

    function test_SetApprovalForAll_Success() public {
        vm.prank(user1);
        token.setApprovalForAll(operator, true);

        assertTrue(token.isApprovedForAll(user1, operator), "Operator should be approved for all");
    }

    function test_SetApprovalForAll_EmitsApprovalForAllEvent() public {
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit ApprovalForAll(user1, operator, true);

        token.setApprovalForAll(operator, true);
    }

    function test_SetApprovalForAll_RevertsWhenApprovingToSelf() public {
        vm.prank(user1);
        vm.expectRevert("ERC721: approve to caller");
        token.setApprovalForAll(user1, true);
    }

    function test_SetApprovalForAll_CanRevoke() public {
        vm.prank(user1);
        token.setApprovalForAll(operator, true);
        assertTrue(token.isApprovedForAll(user1, operator), "Operator should be approved");

        vm.prank(user1);
        token.setApprovalForAll(operator, false);
        assertFalse(token.isApprovedForAll(user1, operator), "Operator should not be approved");
    }

    // ===== IsApprovedForAll Tests =====

    function test_IsApprovedForAll_ReturnsFalseByDefault() public view {
        assertFalse(token.isApprovedForAll(user1, operator), "Should return false by default");
    }

    // ===== OwnerOf Tests =====

    function test_OwnerOf_RevertsWhenTokenDoesNotExist() public {
        vm.expectRevert("ERC721: invalid token ID");
        token.ownerOf(999);
    }

    // ===== BalanceOf Tests =====

    function test_BalanceOf_RevertsWhenZeroAddress() public {
        vm.expectRevert("ERC721: address zero is not a valid owner");
        token.balanceOf(address(0));
    }

    function test_BalanceOf_ReturnsZeroByDefault() public view {
        assertEq(token.balanceOf(user1), 0, "Balance should be 0 by default");
    }

    // ===== TokenURI Tests =====

    function test_TokenURI_ReturnsCorrectURI() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        assertEq(token.tokenURI(tokenId), string(abi.encodePacked(BASE_URI, "1")), "Token URI should match");
    }

    function test_TokenURI_RevertsWhenTokenDoesNotExist() public {
        vm.expectRevert("ERC721: invalid token ID");
        token.tokenURI(999);
    }

    // ===== Edge Case Tests =====

    function test_TransferFrom_WithApproval_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.approve(user2, tokenId);

        vm.prank(user2);
        token.transferFrom(user1, user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
    }

    function test_TransferFrom_WithOperatorApproval_Success() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);

        vm.prank(user1);
        token.setApprovalForAll(operator, true);

        vm.prank(operator);
        token.transferFrom(user1, user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
    }

    function test_MintBurnAndMintAgain() public {
        uint256 tokenId = 1;
        token.mint(user1, tokenId);
        token.burn(tokenId);
        token.mint(user2, tokenId);

        assertEq(token.ownerOf(tokenId), user2, "User2 should own token");
    }
}

// Helper contract for testing safe transfers
contract Receiver is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
