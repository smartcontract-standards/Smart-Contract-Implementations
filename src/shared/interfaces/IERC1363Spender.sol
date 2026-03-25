// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1363Spender
 * @dev Interface for contracts that support ERC1363 approval callbacks
 */
interface IERC1363Spender {
    /**
     * @notice Handle ERC1363 approval callback
     * @param owner The address that approved tokens
     * @param value The approved amount
     * @param data Additional data with no specified format
     * @return bytes4 selector for callback confirmation
     */
    function onApprovalReceived(address owner, uint256 value, bytes calldata data) external returns (bytes4);
}
