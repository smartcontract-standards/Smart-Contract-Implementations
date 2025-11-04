// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC721Receiver
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called
     * @param operator The address which initiated the transfer
     * @param from The address which previously owned the token
     * @param tokenId The token ID
     * @param data Additional data with no specified format
     * @return bytes4 The function selector `IERC721Receiver.onERC721Received.selector`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}
