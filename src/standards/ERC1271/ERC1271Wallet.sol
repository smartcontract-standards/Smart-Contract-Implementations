// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC1271} from "../../shared/interfaces/IERC1271.sol";
import {IERC165} from "../../shared/interfaces/IERC165.sol";

/**
 * @title ERC1271Wallet
 * @dev Implementation of ERC-1271 for smart contract wallets
 * @notice Validates ECDSA signatures from the owner address
 * @custom:security-contact This contract should be audited before use in production
 */
contract ERC1271Wallet is IERC1271 {
    bytes4 private constant _MAGICVALUE = 0x1626ba7e;
    bytes4 private constant _INVALID_SIGNATURE = 0xffffffff;

    address public owner;

    constructor(address owner_) {
        require(owner_ != address(0), "ERC1271: owner is zero");
        owner = owner_;
    }

    /**
     * @dev See {IERC1271-isValidSignature}.
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view override returns (bytes4) {
        if (_recoverSigner(hash, signature) == owner) {
            return _MAGICVALUE;
        }
        return _INVALID_SIGNATURE;
    }

    /**
     * @dev Recover signer from ECDSA signature (65 bytes: r || s || v)
     */
    function _recoverSigner(bytes32 hash, bytes memory signature) private pure returns (address) {
        require(signature.length == 65, "ERC1271: invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) v += 27;
        require(v == 27 || v == 28, "ERC1271: invalid v");
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ERC1271: invalid s"
        );

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ERC1271: invalid signer");
        return signer;
    }
}
