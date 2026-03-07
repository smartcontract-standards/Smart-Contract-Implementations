// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1271
 * @dev Standard Signature Validation Method for Contracts (EIP-1271)
 * @notice See https://eips.ethereum.org/EIPS/eip-1271
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided hash
     * @param hash Hash of the data to be signed
     * @param signature Signature byte array associated with hash
     * @return magicValue MUST return 0x1626ba7e when valid, 0xffffffff otherwise
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
