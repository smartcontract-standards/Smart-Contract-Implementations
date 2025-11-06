// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1155
 * @dev Standard ERC1155 Multi Token Standard interface
 * @notice See https://eips.ethereum.org/EIPS/eip-1155 for full specification
 */
interface IERC1155 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers
     */
    event TransferBatch(
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`
     * @param account The address to query
     * @param id The token ID to query
     * @return balance The balance of the token type
     */
    function balanceOf(address account, uint256 id) external view returns (uint256 balance);

    /**
     * @dev Returns the amount of tokens of each token type `ids` owned by `account`
     * @param account The address to query
     * @param ids The token IDs to query
     * @return balances The balances of each token type
     */
    function balanceOfBatch(address[] calldata account, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory balances);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens
     * @param operator The address to set as operator
     * @param approved True to grant permission, false to revoke
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer `account`'s tokens
     * @param account The address to query
     * @param operator The address to query
     * @return approved True if operator is approved for all
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param id The token ID to transfer
     * @param amount The amount to transfer
     * @param data Additional data with no specified format
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev Transfers `amounts` tokens of token types `ids` from `from` to `to`
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param ids The token IDs to transfer
     * @param amounts The amounts to transfer
     * @param data Additional data with no specified format
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
