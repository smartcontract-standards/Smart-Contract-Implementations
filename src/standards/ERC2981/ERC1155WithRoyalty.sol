// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "../ERC1155/ERC1155.sol";
import {ERC2981} from "./ERC2981.sol";
import {IERC1155} from "../../shared/interfaces/IERC1155.sol";
import {IERC1155MetadataURI} from "../../shared/interfaces/IERC1155MetadataURI.sol";

/**
 * @title ERC1155WithRoyalty
 * @dev ERC1155 Multi-Token with EIP-2981 royalty support
 */
contract ERC1155WithRoyalty is ERC1155, ERC2981 {
    constructor(
        string memory uri_,
        address royaltyReceiver_,
        uint96 royaltyFeeNumerator_
    ) ERC1155(uri_) {
        _setDefaultRoyalty(royaltyReceiver_, royaltyFeeNumerator_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return ERC1155.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }
}
