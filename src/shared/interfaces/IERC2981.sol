// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/**
 * @title IERC2981
 * @dev Interface for the NFT Royalty Standard (EIP-2981)
 * @notice See https://eips.ethereum.org/EIPS/eip-2981 for full specification
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Called with the sale price to determine how much royalty is owed and to whom.
     * @param tokenId The NFT asset queried for royalty information
     * @param salePrice The sale price of the NFT asset specified by tokenId
     * @return receiver Address of who should be sent the royalty payment
     * @return royaltyAmount The royalty payment amount for salePrice
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
