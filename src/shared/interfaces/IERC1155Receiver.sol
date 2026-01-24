// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1155Receiver
 * @dev Interface that must be implemented by smart contracts in order to receive ERC1155 tokens.
 */
interface IERC1155Receiver {
    /**
     * @dev Handles the receipt of a single ERC1155 token type.
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if the transfer is allowed
     */
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types.
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if the transfer is allowed
     */
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external returns (bytes4);
}
