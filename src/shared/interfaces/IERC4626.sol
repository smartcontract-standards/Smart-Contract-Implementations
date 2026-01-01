// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";

/**
 * @title IERC4626
 * @dev Interface of the ERC4626 Tokenized Vault Standard
 * @notice See https://eips.ethereum.org/EIPS/eip-4626 for full specification
 */
interface IERC4626 is IERC20 {
    /**
     * @dev Emitted when `caller` deposits `assets` and receives `shares`
     */
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    /**
     * @dev Emitted when `caller` withdraws `assets` and burns `shares`
     */
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    /**
     * @dev Returns the address of the underlying asset
     */
    function asset() external view returns (address);

    /**
     * @dev Returns the total amount of underlying assets managed by the vault
     */
    function totalAssets() external view returns (uint256);

    /**
     * @dev Converts an `assets` amount to the corresponding amount of shares
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Converts a `shares` amount to the corresponding amount of assets
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of assets that can be deposited for `receiver`
     */
    function maxDeposit(address receiver) external view returns (uint256);

    /**
     * @dev Returns the amount of shares that would be minted by depositing `assets`
     */
    function previewDeposit(uint256 assets) external view returns (uint256);

    /**
     * @dev Deposits `assets` into the vault, returning the amount of shares minted
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of shares that can be minted for `receiver`
     */
    function maxMint(address receiver) external view returns (uint256);

    /**
     * @dev Returns the amount of assets that would be required to mint `shares`
     */
    function previewMint(uint256 shares) external view returns (uint256);

    /**
     * @dev Mints `shares` to `receiver`, taking the required assets from caller
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of assets that can be withdrawn by `owner`
     */
    function maxWithdraw(address owner) external view returns (uint256);

    /**
     * @dev Returns the amount of shares that would be burned to withdraw `assets`
     */
    function previewWithdraw(uint256 assets) external view returns (uint256);

    /**
     * @dev Withdraws `assets` for `receiver` and burns the required shares from `owner`
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of shares that can be redeemed by `owner`
     */
    function maxRedeem(address owner) external view returns (uint256);

    /**
     * @dev Returns the amount of assets that would be received by redeeming `shares`
     */
    function previewRedeem(uint256 shares) external view returns (uint256);

    /**
     * @dev Redeems `shares` from `owner` and sends the corresponding assets to `receiver`
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
