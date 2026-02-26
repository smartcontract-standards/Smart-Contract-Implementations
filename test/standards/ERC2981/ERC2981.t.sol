// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC721RoyaltyTestable} from "../../../src/standards/ERC2981/ERC721RoyaltyTestable.sol";
import {ERC1155RoyaltyTestable} from "../../../src/standards/ERC2981/ERC1155RoyaltyTestable.sol";
import {IERC2981} from "../../../src/shared/interfaces/IERC2981.sol";

contract ERC2981Test is Test {
    address public royaltyReceiver = address(0x1);
    address public user1 = address(0x2);
    uint96 constant ROYALTY_FEE = 750; // 7.5%

    // ===== ERC721 Royalty Tests =====

    function test_ERC721_RoyaltyInfo_ReturnsCorrectAmount() public {
        ERC721RoyaltyTestable nft = new ERC721RoyaltyTestable("Royalty NFT", "RNFT", royaltyReceiver, ROYALTY_FEE);
        nft.mint(user1, 1);

        (address receiver, uint256 amount) = nft.royaltyInfo(1, 10000);

        assertEq(receiver, royaltyReceiver, "Receiver should match");
        assertEq(amount, 750, "7.5% of 10000 should be 750");
    }

    function test_ERC721_RoyaltyInfo_HandlesLargeSalePrice() public {
        ERC721RoyaltyTestable nft = new ERC721RoyaltyTestable("Royalty NFT", "RNFT", royaltyReceiver, ROYALTY_FEE);

        (address receiver, uint256 amount) = nft.royaltyInfo(1, 1 ether);

        assertEq(receiver, royaltyReceiver);
        assertEq(amount, 0.075 ether, "7.5% of 1 ether");
    }

    function test_ERC721_RoyaltyInfo_ZeroSalePrice() public {
        ERC721RoyaltyTestable nft = new ERC721RoyaltyTestable("Royalty NFT", "RNFT", royaltyReceiver, ROYALTY_FEE);

        (address receiver, uint256 amount) = nft.royaltyInfo(1, 0);

        assertEq(receiver, royaltyReceiver);
        assertEq(amount, 0);
    }

    function test_ERC721_SupportsInterface_ERC2981() public {
        ERC721RoyaltyTestable nft = new ERC721RoyaltyTestable("Royalty NFT", "RNFT", royaltyReceiver, ROYALTY_FEE);

        assertTrue(nft.supportsInterface(type(IERC2981).interfaceId));
    }

    // ===== ERC1155 Royalty Tests =====

    function test_ERC1155_RoyaltyInfo_ReturnsCorrectAmount() public {
        ERC1155RoyaltyTestable token =
            new ERC1155RoyaltyTestable("https://example.com/{id}.json", royaltyReceiver, ROYALTY_FEE);
        token.mint(user1, 1, 100, "");

        (address receiver, uint256 amount) = token.royaltyInfo(1, 10000);

        assertEq(receiver, royaltyReceiver, "Receiver should match");
        assertEq(amount, 750, "7.5% of 10000 should be 750");
    }

    function test_ERC1155_RoyaltyInfo_HandlesLargeSalePrice() public {
        ERC1155RoyaltyTestable token =
            new ERC1155RoyaltyTestable("https://example.com/{id}.json", royaltyReceiver, ROYALTY_FEE);

        (address receiver, uint256 amount) = token.royaltyInfo(1, 10 ether);

        assertEq(receiver, royaltyReceiver);
        assertEq(amount, 0.75 ether, "7.5% of 10 ether");
    }

    function test_ERC1155_SupportsInterface_ERC2981() public {
        ERC1155RoyaltyTestable token =
            new ERC1155RoyaltyTestable("https://example.com/{id}.json", royaltyReceiver, ROYALTY_FEE);

        assertTrue(token.supportsInterface(type(IERC2981).interfaceId));
    }
}
