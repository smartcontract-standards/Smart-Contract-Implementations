// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1155MetadataURI
 * @dev ERC1155 Metadata URI extension interface
 */
interface IERC1155MetadataURI {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
