// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "../ERC721/ERC721.sol";
import {ERC2981} from "./ERC2981.sol";
import {IERC165} from "../../shared/interfaces/IERC165.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {IERC721Metadata} from "../../shared/interfaces/IERC721Metadata.sol";

/**
 * @title ERC721WithRoyalty
 * @dev ERC721 NFT with EIP-2981 royalty support
 */
contract ERC721WithRoyalty is ERC721, ERC2981 {
    constructor(
        string memory name_,
        string memory symbol_,
        address royaltyReceiver_,
        uint96 royaltyFeeNumerator_
    ) ERC721(name_, symbol_) {
        _setDefaultRoyalty(royaltyReceiver_, royaltyFeeNumerator_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }
}
