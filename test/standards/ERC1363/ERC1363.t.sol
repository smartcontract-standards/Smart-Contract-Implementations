// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC1363Testable} from "../../../src/standards/ERC1363/ERC1363Testable.sol";
import {IERC1363Receiver} from "../../../src/shared/interfaces/IERC1363Receiver.sol";
import {IERC1363Spender} from "../../../src/shared/interfaces/IERC1363Spender.sol";
import {IERC1363} from "../../../src/shared/interfaces/IERC1363.sol";
import {IERC165} from "../../../src/shared/interfaces/IERC165.sol";

contract ERC1363ReceiverMock is IERC1363Receiver {
    bytes4 public response;
    address public operator;
    address public from;
    uint256 public value;
    bytes public data;

    constructor(bytes4 response_) {
        response = response_;
    }

    function onTransferReceived(address operator_, address from_, uint256 value_, bytes calldata data_)
        external
        override
        returns (bytes4)
    {
        operator = operator_;
        from = from_;
        value = value_;
        data = data_;
        return response;
    }
}

contract ERC1363SpenderMock is IERC1363Spender {
    bytes4 public response;
    address public owner;
    uint256 public value;
    bytes public data;

    constructor(bytes4 response_) {
        response = response_;
    }

    function onApprovalReceived(address owner_, uint256 value_, bytes calldata data_)
        external
        override
        returns (bytes4)
    {
        owner = owner_;
        value = value_;
        data = data_;
        return response;
    }
}

contract NonReceiver {}

contract ERC1363Test is Test {
    ERC1363Testable public token;

    string constant NAME = "Payable Token";
    string constant SYMBOL = "PAY";
    uint8 constant DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1_000_000e18;

    address public owner = address(0x1);
    address public user1 = address(0x2);

    ERC1363ReceiverMock public receiver;
    ERC1363ReceiverMock public badReceiver;
    ERC1363SpenderMock public spender;
    ERC1363SpenderMock public badSpender;
    NonReceiver public eoaLike;

    function setUp() public {
        vm.prank(owner);
        token = new ERC1363Testable(NAME, SYMBOL, DECIMALS, INITIAL_SUPPLY);

        receiver = new ERC1363ReceiverMock(IERC1363Receiver.onTransferReceived.selector);
        badReceiver = new ERC1363ReceiverMock(bytes4(0xdeadbeef));
        spender = new ERC1363SpenderMock(IERC1363Spender.onApprovalReceived.selector);
        badSpender = new ERC1363SpenderMock(bytes4(0xdeadbeef));
        eoaLike = new NonReceiver();
    }

    function test_TransferAndCall_Success() public {
        vm.prank(owner);
        bool ok = token.transferAndCall(address(receiver), 100e18, bytes("hello"));

        assertTrue(ok);
        assertEq(token.balanceOf(address(receiver)), 100e18);
        assertEq(receiver.operator(), owner);
        assertEq(receiver.from(), owner);
        assertEq(receiver.value(), 100e18);
        assertEq(receiver.data(), bytes("hello"));
    }

    function test_TransferAndCall_RevertWhenReceiverNotContract() public {
        vm.prank(owner);
        vm.expectRevert("ERC1363: receiver is not contract");
        token.transferAndCall(user1, 1e18);
    }

    function test_TransferAndCall_RevertWhenInvalidReceiverReturn() public {
        vm.prank(owner);
        vm.expectRevert("ERC1363: invalid receiver return");
        token.transferAndCall(address(badReceiver), 1e18);
    }

    function test_TransferFromAndCall_Success() public {
        vm.prank(owner);
        token.approve(user1, 50e18);

        vm.prank(user1);
        bool ok = token.transferFromAndCall(owner, address(receiver), 50e18, bytes("x"));

        assertTrue(ok);
        assertEq(token.balanceOf(address(receiver)), 50e18);
        assertEq(receiver.operator(), user1);
        assertEq(receiver.from(), owner);
    }

    function test_ApproveAndCall_Success() public {
        vm.prank(owner);
        bool ok = token.approveAndCall(address(spender), 123e18, bytes("data"));

        assertTrue(ok);
        assertEq(token.allowance(owner, address(spender)), 123e18);
        assertEq(spender.owner(), owner);
        assertEq(spender.value(), 123e18);
        assertEq(spender.data(), bytes("data"));
    }

    function test_ApproveAndCall_RevertWhenSpenderNotContract() public {
        vm.prank(owner);
        vm.expectRevert("ERC1363: spender is not contract");
        token.approveAndCall(user1, 1e18);
    }

    function test_ApproveAndCall_RevertWhenInvalidSpenderReturn() public {
        vm.prank(owner);
        vm.expectRevert("ERC1363: invalid spender return");
        token.approveAndCall(address(badSpender), 1e18);
    }

    function test_SupportsInterface_ERC1363() public view {
        assertTrue(token.supportsInterface(type(IERC1363).interfaceId));
    }

    function test_SupportsInterface_ERC165() public view {
        assertTrue(token.supportsInterface(type(IERC165).interfaceId));
    }
}
