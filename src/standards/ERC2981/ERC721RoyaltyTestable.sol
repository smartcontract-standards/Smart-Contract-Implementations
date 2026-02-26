// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721WithRoyalty} from "./ERC721WithRoyalty.sol";

/**
 * @title ERC721RoyaltyTestable
 * @dev Testable ERC721 with royalty - exposes mint/burn for testing
 */
contract ERC721RoyaltyTestable is ERC721WithRoyalty {
    constructor(
        string memory name_,
        string memory symbol_,
        address royaltyReceiver_,
        uint96 royaltyFeeNumerator_
    ) ERC721WithRoyalty(name_, symbol_, royaltyReceiver_, royaltyFeeNumerator_) {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}
