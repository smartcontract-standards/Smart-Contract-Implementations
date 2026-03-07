// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {FlashLender} from "../../../src/standards/ERC3156/FlashLender.sol";
import {FlashBorrower} from "../../../src/standards/ERC3156/FlashBorrower.sol";
import {IERC20} from "../../../src/shared/interfaces/IERC20.sol";
import {ERC20} from "../../../src/standards/ERC20/ERC20.sol";
import {ERC20Testable} from "../../../src/standards/ERC20/ERC20Testable.sol";

contract ERC3156Test is Test {
    FlashLender public lender;
    FlashBorrower public borrower;
    ERC20Testable public token;

    address public liquidityProvider = address(0x1);
    uint256 public constant FEE_BPS = 9; // 0.09%
    uint256 public constant INITIAL_SUPPLY = 1_000_000e18;

    function setUp() public {
        vm.prank(liquidityProvider);
        token = new ERC20Testable("Test Token", "TST", 18, INITIAL_SUPPLY);

        lender = new FlashLender(address(token), FEE_BPS);
        borrower = new FlashBorrower();

        vm.startPrank(liquidityProvider);
        token.approve(address(lender), INITIAL_SUPPLY);
        lender.deposit(100_000e18); // 100k tokens for lending
        vm.stopPrank();
    }

    function test_MaxFlashLoan_SupportedToken() public view {
        assertEq(lender.maxFlashLoan(address(token)), 100_000e18);
    }

    function test_MaxFlashLoan_UnsupportedToken_ReturnsZero() public view {
        assertEq(lender.maxFlashLoan(address(0xdead)), 0);
    }

    function test_FlashFee_SupportedToken() public view {
        uint256 amount = 1000e18;
        uint256 fee = lender.flashFee(address(token), amount);
        assertEq(fee, (amount * FEE_BPS) / 10_000);
    }

    function test_FlashFee_UnsupportedToken_Reverts() public {
        vm.expectRevert("FlashLender: unsupported token");
        lender.flashFee(address(0xdead), 1000e18);
    }

    function test_FlashLoan_Success() public {
        uint256 amount = 10_000e18;
        uint256 fee = (amount * FEE_BPS) / 10_000;
        uint256 balanceBefore = token.balanceOf(address(lender));

        // Borrower needs tokens to pay the fee; fund from liquidity provider
        vm.prank(liquidityProvider);
        token.transfer(address(borrower), fee);

        borrower.executeFlashLoan(lender, address(token), amount, "");

        assertEq(token.balanceOf(address(lender)), balanceBefore + fee);
    }

    function test_FlashLoan_UnsupportedToken_Reverts() public {
        vm.expectRevert("FlashLender: unsupported token");
        borrower.executeFlashLoan(lender, address(0xdead), 1000e18, "");
    }

    function test_FlashLoan_ZeroAmount_Reverts() public {
        vm.expectRevert("FlashLender: zero amount");
        borrower.executeFlashLoan(lender, address(token), 0, "");
    }
}
