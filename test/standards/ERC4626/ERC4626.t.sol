// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC20Testable} from "../../../src/standards/ERC20/ERC20Testable.sol";
import {ERC4626Testable} from "../../../src/standards/ERC4626/ERC4626Testable.sol";

contract ERC4626Test is Test {
    ERC20Testable public asset;
    ERC4626Testable public vault;

    uint256 constant INITIAL_ASSETS = 1_000e18;
    uint256 constant DEPOSIT_AMOUNT = 100e18;

    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    function setUp() public {
        asset = new ERC20Testable("Mock Asset", "MA", 18, 0);
        vault = new ERC4626Testable(address(asset), "Mock Vault", "vMA");

        asset.mint(owner, INITIAL_ASSETS);
        asset.mint(user1, INITIAL_ASSETS);
        asset.mint(user2, INITIAL_ASSETS);
    }

    // ===== Metadata Tests =====

    function test_Metadata_Matches() public view {
        assertEq(vault.name(), "Mock Vault", "Vault name should match");
        assertEq(vault.symbol(), "vMA", "Vault symbol should match");
        assertEq(vault.decimals(), asset.decimals(), "Vault decimals should match asset");
        assertEq(vault.asset(), address(asset), "Vault asset should match");
    }

    // ===== Deposit Tests =====

    function test_Deposit_Success() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        uint256 shares = vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        assertEq(shares, DEPOSIT_AMOUNT, "Shares should equal assets on first deposit");
        assertEq(vault.balanceOf(owner), DEPOSIT_AMOUNT, "Owner shares should match");
        assertEq(vault.totalSupply(), DEPOSIT_AMOUNT, "Total supply should match shares");
        assertEq(vault.totalAssets(), DEPOSIT_AMOUNT, "Total assets should match deposit");
    }

    function test_Deposit_EmitsEvent() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vm.expectEmit(true, true, false, true);
        emit Deposit(owner, owner, DEPOSIT_AMOUNT, DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();
    }

    function test_Deposit_RevertsWhenZeroAssets() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC4626: assets must be greater than zero");
        vault.deposit(0, owner);
    }

    function test_Deposit_RevertsWhenReceiverZero() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC4626: deposit to zero address");
        vault.deposit(DEPOSIT_AMOUNT, address(0));
    }

    // ===== Mint Tests =====

    function test_Mint_Success() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        uint256 assetsRequired = vault.mint(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        assertEq(assetsRequired, DEPOSIT_AMOUNT, "Assets required should equal shares on first mint");
        assertEq(vault.balanceOf(owner), DEPOSIT_AMOUNT, "Owner shares should match");
        assertEq(asset.balanceOf(address(vault)), DEPOSIT_AMOUNT, "Vault assets should match");
    }

    function test_Mint_RevertsWhenZeroShares() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC4626: shares must be greater than zero");
        vault.mint(0, owner);
    }

    // ===== Withdraw Tests =====

    function test_Withdraw_Success() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        uint256 sharesBurned = vault.withdraw(40e18, owner, owner);
        vm.stopPrank();

        assertEq(sharesBurned, 40e18, "Shares burned should equal assets withdrawn");
        assertEq(vault.balanceOf(owner), DEPOSIT_AMOUNT - 40e18, "Owner shares should reduce");
        assertEq(asset.balanceOf(owner), INITIAL_ASSETS - DEPOSIT_AMOUNT + 40e18, "Owner assets should adjust");
        assertEq(vault.totalAssets(), DEPOSIT_AMOUNT - 40e18, "Vault assets should reduce");
    }

    function test_Withdraw_WithApproval() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vault.approve(user1, type(uint256).max);
        vm.stopPrank();

        vm.prank(user1);
        uint256 sharesBurned = vault.withdraw(60e18, owner, owner);

        assertEq(sharesBurned, 60e18, "Shares burned should equal assets withdrawn");
        assertEq(vault.balanceOf(owner), DEPOSIT_AMOUNT - 60e18, "Owner shares should reduce");
    }

    function test_Withdraw_RevertsWhenNotOwnerOrApproved() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert("ERC4626: insufficient allowance");
        vault.withdraw(10e18, owner, owner);
    }

    function test_Withdraw_RevertsWhenZeroAssets() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC4626: assets must be greater than zero");
        vault.withdraw(0, owner, owner);
    }

    // ===== Redeem Tests =====

    function test_Redeem_Success() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        uint256 assetsReturned = vault.redeem(70e18, owner, owner);
        vm.stopPrank();

        assertEq(assetsReturned, 70e18, "Assets returned should equal shares redeemed");
        assertEq(vault.balanceOf(owner), DEPOSIT_AMOUNT - 70e18, "Owner shares should reduce");
        assertEq(vault.totalAssets(), DEPOSIT_AMOUNT - 70e18, "Vault assets should reduce");
    }

    function test_Redeem_WithApproval() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vault.approve(user1, type(uint256).max);
        vm.stopPrank();

        vm.prank(user1);
        uint256 assetsReturned = vault.redeem(20e18, owner, owner);

        assertEq(assetsReturned, 20e18, "Assets returned should equal shares redeemed");
        assertEq(vault.balanceOf(owner), DEPOSIT_AMOUNT - 20e18, "Owner shares should reduce");
    }

    function test_Redeem_RevertsWhenZeroShares() public {
        vm.startPrank(owner);
        vm.expectRevert("ERC4626: shares must be greater than zero");
        vault.redeem(0, owner, owner);
    }

    // ===== Preview Tests =====

    function test_PreviewDepositAndMint() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        assertEq(vault.previewDeposit(50e18), 50e18, "Preview deposit should be 1:1");
        assertEq(vault.previewMint(50e18), 50e18, "Preview mint should be 1:1");
    }

    function test_PreviewWithdrawAndRedeem() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        assertEq(vault.previewWithdraw(40e18), 40e18, "Preview withdraw should be 1:1");
        assertEq(vault.previewRedeem(40e18), 40e18, "Preview redeem should be 1:1");
    }

    function test_PreviewMintRoundsUp() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        // Simulate yield: vault balance increases without new shares
        asset.mint(address(vault), 10e18);

        uint256 assetsRequired = vault.previewMint(50e18);
        assertGt(assetsRequired, 45e18, "Assets required should round up");
    }

    function test_PreviewWithdrawRoundsUp() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        asset.mint(address(vault), 10e18);

        uint256 sharesRequired = vault.previewWithdraw(50e18);
        assertLt(sharesRequired, 50e18, "Shares required should round up towards extra precision");
    }

    // ===== Max Functions =====

    function test_MaxFunctions() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        assertEq(vault.maxDeposit(owner), type(uint256).max, "Max deposit should be unlimited");
        assertEq(vault.maxMint(owner), type(uint256).max, "Max mint should be unlimited");
        assertEq(vault.maxWithdraw(owner), DEPOSIT_AMOUNT, "Max withdraw should equal assets");
        assertEq(vault.maxRedeem(owner), DEPOSIT_AMOUNT, "Max redeem should equal shares");
    }

    // ===== Allowance Tests =====

    function test_ApproveAndTransfer() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vault.approve(user1, 30e18);
        vm.stopPrank();

        vm.prank(user1);
        vault.transferFrom(owner, user2, 20e18);

        assertEq(vault.balanceOf(user2), 20e18, "User2 should receive shares");
        assertEq(vault.allowance(owner, user1), 10e18, "Allowance should decrease");
    }

    function test_Transfer() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        vm.prank(owner);
        vault.transfer(user1, 25e18);

        assertEq(vault.balanceOf(user1), 25e18, "User1 should receive shares");
    }

    // ===== Yield Simulation =====

    function test_VaultAccruesYield() public {
        vm.startPrank(owner);
        asset.approve(address(vault), DEPOSIT_AMOUNT);
        vault.deposit(DEPOSIT_AMOUNT, owner);
        vm.stopPrank();

        // Simulate yield of 50 tokens
        asset.mint(address(vault), 50e18);

        uint256 assets = vault.previewRedeem(DEPOSIT_AMOUNT);
        assertEq(assets, DEPOSIT_AMOUNT + 50e18, "Redeem should include yield");
    }
}
