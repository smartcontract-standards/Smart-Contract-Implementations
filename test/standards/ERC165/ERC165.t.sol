// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC165Testable} from "../../../src/standards/ERC165/ERC165Testable.sol";
import {IERC165} from "../../../src/shared/interfaces/IERC165.sol";

contract ERC165Test is Test {
    ERC165Testable public erc165;

    function setUp() public {
        erc165 = new ERC165Testable();
    }

    function test_SupportsInterface_ERC165() public view {
        assertTrue(erc165.supportsInterface(type(IERC165).interfaceId));
    }

    function test_SupportsInterface_CustomFoo() public view {
        assertTrue(erc165.supportsInterface(erc165.FOO_INTERFACE()));
    }

    function test_SupportsInterface_UnknownReturnsFalse() public view {
        assertFalse(erc165.supportsInterface(0xdeadbeef));
    }

    function test_SupportsInterface_InvalidIdReturnsFalse() public view {
        assertFalse(erc165.supportsInterface(0xffffffff));
    }

    function test_FooReturns42() public view {
        assertEq(erc165.foo(), 42);
    }
}
