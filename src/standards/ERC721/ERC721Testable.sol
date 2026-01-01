// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "./ERC721.sol";

/**
 * @title ERC721Testable
 * @dev Testable version of ERC721 that exposes internal functions for testing
 * @notice DO NOT use this in production - use ERC721 instead
 */
contract ERC721Testable is ERC721 {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}
    constructor(string memory name_, string memory symbol_, string memory baseURI_) ERC721(name_, symbol_, baseURI_) {}

    /**
     * @dev Exposes _mint for testing purposes
     */
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    /**
     * @dev Exposes _safeMint for testing purposes
     */
    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }

    /**
     * @dev Exposes _safeMint with data for testing purposes
     */
    function safeMint(address to, uint256 tokenId, bytes memory data) external {
        _safeMint(to, tokenId, data);
    }

    /**
     * @dev Exposes _burn for testing purposes
     */
    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    // exists() is already public in ERC721, no need to override
}

}
