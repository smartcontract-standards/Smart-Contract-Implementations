// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC2981} from "../../shared/interfaces/IERC2981.sol";
import {IERC165} from "../../shared/interfaces/IERC165.sol";

/**
 * @title ERC2981
 * @dev Implementation of the NFT Royalty Standard (EIP-2981)
 * @notice Provides royalty info as a percentage of sale price (basis points, 10000 = 100%)
 */
abstract contract ERC2981 is IERC2981 {
    // Default royalty: receiver address and fee in basis points (e.g. 750 = 7.5%)
    address private _defaultRoyaltyReceiver;
    uint96 private _defaultRoyaltyFeeNumerator;

    // Fee denominator for basis points (10000 = 100%)
    uint96 private constant _FEE_DENOMINATOR = 10000;

    /**
     * @dev Sets default royalty recipient and fee.
     * @param receiver Address to receive royalties
     * @param feeNumerator Fee in basis points (e.g. 750 = 7.5%)
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(receiver != address(0), "ERC2981: zero address receiver");
        require(feeNumerator <= _FEE_DENOMINATOR, "ERC2981: fee exceeds denominator");

        _defaultRoyaltyReceiver = receiver;
        _defaultRoyaltyFeeNumerator = feeNumerator;
    }

    /**
     * @dev Removes default royalty info.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyReceiver;
        delete _defaultRoyaltyFeeNumerator;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev See {IERC2981-royaltyInfo}.
     */
    function royaltyInfo(uint256 /* tokenId */, uint256 salePrice)
        public
        view
        virtual
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _defaultRoyaltyReceiver;
        royaltyAmount = (salePrice * _defaultRoyaltyFeeNumerator) / _FEE_DENOMINATOR;
    }
}
