// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1363Receiver
 * @dev Interface for contracts that support ERC1363 transfer callbacks
 */
interface IERC1363Receiver {
    /**
     * @notice Handle the receipt of ERC1363 tokens
     * @param operator The address that initiated transferAndCall/transferFromAndCall
     * @param from The address tokens were transferred from
     * @param value The amount transferred
     * @param data Additional data with no specified format
     * @return bytes4 selector for callback confirmation
     */
    function onTransferReceived(address operator, address from, uint256 value, bytes calldata data)
        external
        returns (bytes4);
}
