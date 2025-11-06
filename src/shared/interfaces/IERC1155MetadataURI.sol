// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC1155} from "./IERC1155.sol";

/**
 * @title IERC1155MetadataURI
 * @dev Extension of IERC1155 that includes metadata URI functions
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`
     * @param id The token ID to query
     * @return uri The URI string
     */
    function uri(uint256 id) external view returns (string memory);
}
