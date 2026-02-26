// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155WithRoyalty} from "./ERC1155WithRoyalty.sol";

/**
 * @title ERC1155RoyaltyTestable
 * @dev Testable ERC1155 with royalty - exposes mint/burn for testing
 */
contract ERC1155RoyaltyTestable is ERC1155WithRoyalty {
    constructor(
        string memory uri_,
        address royaltyReceiver_,
        uint96 royaltyFeeNumerator_
    ) ERC1155WithRoyalty(uri_, royaltyReceiver_, royaltyFeeNumerator_) {}

    function mint(address to, uint256 id, uint256 amount, bytes memory data) external {
        _mint(to, id, amount, data);
    }

    function burn(address from, uint256 id, uint256 amount) external {
        _burn(from, id, amount);
    }
}
