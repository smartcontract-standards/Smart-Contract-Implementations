// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1155Receiver
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC1155 asset contracts
 */
interface IERC1155Receiver {
    /**
     * @dev Handles the receipt of a single ERC1155 token type
     * @param operator The address which initiated the transfer
     * @param from The address which previously owned the token
     * @param id The token ID
     * @param value The amount of tokens transferred
     * @param data Additional data with no specified format
     * @return bytes4 The function selector `IERC1155Receiver.onERC1155Received.selector`
     */
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
        external
        returns (bytes4);

    /**
     * @dev Handles the receipt of multiple ERC1155 token types
     * @param operator The address which initiated the transfer
     * @param from The address which previously owned the token
     * @param ids The token IDs
     * @param values The amounts of tokens transferred
     * @param data Additional data with no specified format
     * @return bytes4 The function selector `IERC1155Receiver.onERC1155BatchReceived.selector`
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
