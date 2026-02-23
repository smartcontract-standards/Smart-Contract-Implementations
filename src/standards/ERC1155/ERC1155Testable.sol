// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "./ERC1155.sol";

/**
 * @title ERC1155Testable
 * @dev Extension of ERC1155 that exposes internal functions for testing purposes
 */
contract ERC1155Testable is ERC1155 {
    constructor(string memory uri_) ERC1155(uri_) {}

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public {
        _mint(to, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public {
        _mintBatch(to, ids, amounts, data);
    }

    function burn(address from, uint256 id, uint256 amount) public {
        _burn(from, id, amount);
    }

    function burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) public {
        _burnBatch(from, ids, amounts);
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }
}
