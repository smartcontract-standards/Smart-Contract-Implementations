// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../ERC20/ERC20.sol";
import {IERC20Permit} from "../../shared/interfaces/IERC20Permit.sol";

/**
 * @title ERC20Permit
 * @dev ERC20 with gasless approval via EIP-2612 permit
 * @notice Extends ERC20 with permit for signed approvals
 * @custom:security-contact This contract should be audited before use in production
 */
abstract contract ERC20Permit is ERC20, IERC20Permit {
    mapping(address => uint256) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _DOMAIN_SEPARATOR;

    /**
     * @dev EIP-712 domain version
     */
    string private constant _VERSION = "1";

    /**
     * @dev Initializes the domain separator
     */
    constructor() {
        _DOMAIN_SEPARATOR = _buildDomainSeparator();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        require(owner != address(0), "ERC20Permit: zero address owner");

        uint256 currentNonce = _nonces[owner];
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, currentNonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", _DOMAIN_SEPARATOR, structHash));

        address signer = _recover(digest, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        unchecked {
            _nonces[owner] = currentNonce + 1;
        }

        _approve(owner, spender, value);
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes(_VERSION)),
                block.chainid,
                address(this)
            )
        );
    }

    function _recover(bytes32 digest, uint8 v, bytes32 r, bytes32 s) private pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ERC20Permit: invalid s");
        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0), "ERC20Permit: invalid signature");
        return signer;
    }
}
