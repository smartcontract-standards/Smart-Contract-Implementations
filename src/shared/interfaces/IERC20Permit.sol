// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC20Permit
 * @dev ERC20 Permit extension interface (EIP-2612)
 * @notice See https://eips.ethereum.org/EIPS/eip-2612 for full specification
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over `owner`'s tokens, given a signature.
     * @param owner The address that holds the tokens
     * @param spender The address that will spend the tokens
     * @param value The amount of allowance
     * @param deadline The deadline timestamp (uint256(-1) for no expiration)
     * @param v Recovery byte of the signature
     * @param r First 32 bytes of the signature
     * @param s Second 32 bytes of the signature
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}.
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
