// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "./IERC721.sol";

/**
 * @title IERC721Metadata
 * @dev ERC721 token with metadata extension
 * @notice See https://eips.ethereum.org/EIPS/eip-721 for full specification
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     * @param tokenId The token ID to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

