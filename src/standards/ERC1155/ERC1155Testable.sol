// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "./ERC1155.sol";

/**
 * @title ERC1155Testable
 * @dev Testable version of ERC1155 that exposes internal functions for testing
 * @notice DO NOT use this in production - use ERC1155 instead
 */
contract ERC1155Testable is ERC1155 {
    constructor(string memory uri_) ERC1155(uri_) {}

    /**
     * @dev Exposes _mint for testing purposes
     */
    function mint(address to, uint256 id, uint256 amount, bytes memory data) external {
        _mint(to, id, amount, data);
    }

    /**
     * @dev Exposes _mintBatch for testing purposes
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Exposes _burn for testing purposes
     */
    function burn(address from, uint256 id, uint256 amount) external {
        _burn(from, id, amount);
    }

    /**
     * @dev Exposes _burnBatch for testing purposes
     */
    function burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) external {
        _burnBatch(from, ids, amounts);
    }
}
