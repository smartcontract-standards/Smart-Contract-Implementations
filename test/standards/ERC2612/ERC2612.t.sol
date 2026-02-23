// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC20PermitTestable} from "../../../src/standards/ERC2612/ERC20PermitTestable.sol";

contract ERC2612Test is Test {
    ERC20PermitTestable public token;

    string constant NAME = "Permit Token";
    string constant SYMBOL = "PRM";
    uint8 constant DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1000000e18;

    // Use Foundry's default account 1 for signing (private key 1)
    uint256 constant OWNER_KEY = 1;
    address public owner;
    address public spender = address(0x2);
    address public relayer = address(0x3);

    bytes32 constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        owner = vm.addr(OWNER_KEY);
        vm.prank(owner);
        token = new ERC20PermitTestable(NAME, SYMBOL, DECIMALS, INITIAL_SUPPLY);
    }

    function _getPermitDigest(address owner_, address spender_, uint256 value, uint256 nonce, uint256 deadline)
        internal
        view
        returns (bytes32)
    {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner_, spender_, value, nonce, deadline));
        return keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));
    }

    // ===== Permit Tests =====

    function test_Permit_Success() public {
        uint256 value = 100e18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        token.permit(owner, spender, value, deadline, v, r, s);

        assertEq(token.allowance(owner, spender), value, "Allowance should be set");
    }

    function test_Permit_EmitsApprovalEvent() public {
        uint256 value = 100e18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, spender, value);
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_Permit_IncrementsNonce() public {
        uint256 value = 100e18;
        uint256 deadline = block.timestamp + 1 hours;

        uint256 nonceBefore = token.nonces(owner);
        bytes32 digest = _getPermitDigest(owner, spender, value, nonceBefore, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        token.permit(owner, spender, value, deadline, v, r, s);

        assertEq(token.nonces(owner), nonceBefore + 1, "Nonce should increment");
    }

    function test_Permit_TransferFromAfterPermit() public {
        uint256 value = 500e18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        token.permit(owner, spender, value, deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, relayer, 300e18);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - 300e18);
        assertEq(token.balanceOf(relayer), 300e18);
        assertEq(token.allowance(owner, spender), 200e18);
    }

    function test_Permit_RevertsWhenExpired() public {
        uint256 value = 100e18;
        uint256 deadline = block.timestamp - 1; // Already expired
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        vm.expectRevert("ERC20Permit: expired deadline");
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_Permit_RevertsWhenInvalidSignature() public {
        uint256 value = 100e18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        // Sign with wrong key (2 instead of 1) - recovered address won't match owner
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, digest);

        vm.prank(relayer);
        vm.expectRevert("ERC20Permit: invalid signature");
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_Permit_RevertsWhenReusedNonce() public {
        uint256 value = 100e18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        token.permit(owner, spender, value, deadline, v, r, s);

        vm.prank(relayer);
        vm.expectRevert("ERC20Permit: invalid signature");
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_Permit_WorksWithMaxDeadline() public {
        uint256 value = 100e18;
        uint256 deadline = type(uint256).max;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = _getPermitDigest(owner, spender, value, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OWNER_KEY, digest);

        vm.prank(relayer);
        token.permit(owner, spender, value, deadline, v, r, s);

        assertEq(token.allowance(owner, spender), value);
    }

    // ===== Domain Separator Tests =====

    function test_DomainSeparator_IsConsistent() public view {
        bytes32 ds = token.DOMAIN_SEPARATOR();
        assertTrue(ds != bytes32(0), "Domain separator should not be zero");
    }

    // ===== Nonces Tests =====

    function test_Nonces_StartsAtZero() public view {
        assertEq(token.nonces(owner), 0);
    }
}
