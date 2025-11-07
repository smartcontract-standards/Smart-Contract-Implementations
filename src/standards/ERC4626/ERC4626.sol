// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {IERC20Metadata} from "../../shared/interfaces/IERC20Metadata.sol";
import {IERC4626} from "../../shared/interfaces/IERC4626.sol";

/**
 * @title ERC4626
 * @dev Implementation of the ERC4626 Tokenized Vault Standard
 * @notice This contract allows deposits of an underlying ERC20 asset in exchange for share tokens
 * @custom:security-contact This contract should be audited before use in production
 */
contract ERC4626 is IERC4626 {
    // Vault metadata
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;

    // Underlying asset
    IERC20 private immutable _asset;
    IERC20Metadata private immutable _assetMetadata;

    // Balances mapping: address => share balance
    mapping(address => uint256) private _balances;

    // Allowances mapping: owner => spender => allowance
    mapping(address => mapping(address => uint256)) private _allowances;

    // Total supply of shares
    uint256 private _totalSupply;

    /**
     * @dev Creates an ERC4626 vault for the given ERC20 asset
     * @param asset_ The address of the underlying ERC20 asset
     * @param name_ Vault share token name
     * @param symbol_ Vault share token symbol
     */
    constructor(address asset_, string memory name_, string memory symbol_) {
        require(asset_ != address(0), "ERC4626: asset is zero address");
        _asset = IERC20(asset_);
        _assetMetadata = IERC20Metadata(asset_);
        _name = name_;
        _symbol = symbol_;
        _decimals = _assetMetadata.decimals();
    }

    /**
     * @dev Returns the name of the share token
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the share token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the decimals of the share token (matches underlying asset)
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the balance of shares for the specified address
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Returns the total supply of shares
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the allowance of shares from owner to spender
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approves `spender` to spend `amount` shares on behalf of caller
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` shares to `to`
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` shares from `from` to `to` using allowance
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Returns the address of the underlying asset
     */
    function asset() public view override returns (address) {
        return address(_asset);
    }

    /**
     * @dev Returns the total amount of underlying assets managed by the vault
     */
    function totalAssets() public view override returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    /**
     * @dev Converts an `assets` amount to the corresponding amount of shares (rounding down)
     */
    function convertToShares(uint256 assets) public view override returns (uint256) {
        uint256 supply = _totalSupply;
        if (supply == 0) {
            return assets;
        }

        uint256 totalManaged = totalAssets();
        if (totalManaged == 0) {
            return 0;
        }

        return (assets * supply) / totalManaged;
    }

    /**
     * @dev Converts a `shares` amount to the corresponding amount of assets (rounding down)
     */
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        uint256 supply = _totalSupply;
        if (supply == 0) {
            return shares;
        }

        uint256 totalManaged = totalAssets();
        if (totalManaged == 0) {
            return 0;
        }

        return (shares * totalManaged) / supply;
    }

    /**
     * @dev Returns the maximum amount of assets that can be deposited for `receiver`
     */
    function maxDeposit(address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @dev Returns the amount of shares that would be minted by depositing `assets`
     */
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        return convertToShares(assets);
    }

    /**
     * @dev Deposits `assets` into the vault, returning the amount of shares minted
     */
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        require(receiver != address(0), "ERC4626: deposit to zero address");
        require(assets > 0, "ERC4626: assets must be greater than zero");

        shares = previewDeposit(assets);
        require(shares > 0, "ERC4626: shares is zero");

        _transferAssetsFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @dev Returns the maximum amount of shares that can be minted for `receiver`
     */
    function maxMint(address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @dev Returns the amount of assets that would be required to mint `shares`
     */
    function previewMint(uint256 shares) public view override returns (uint256) {
        uint256 supply = _totalSupply;
        if (shares == 0) {
            return 0;
        }

        if (supply == 0) {
            return shares;
        }

        uint256 totalManaged = totalAssets();
        if (totalManaged == 0) {
            return shares;
        }

        return _mulDivUp(shares, totalManaged, supply);
    }

    /**
     * @dev Mints `shares` to `receiver`, taking the required assets from caller
     */
    function mint(uint256 shares, address receiver) public override returns (uint256 assets) {
        require(receiver != address(0), "ERC4626: mint to zero address");
        require(shares > 0, "ERC4626: shares must be greater than zero");

        assets = previewMint(shares);
        require(assets > 0, "ERC4626: assets is zero");

        _transferAssetsFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /**
     * @dev Returns the maximum amount of assets that can be withdrawn by `owner`
     */
    function maxWithdraw(address owner) public view override returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }

    /**
     * @dev Returns the amount of shares that would be burned to withdraw `assets`
     */
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        uint256 supply = _totalSupply;
        if (assets == 0) {
            return 0;
        }

        if (supply == 0) {
            return assets;
        }

        uint256 totalManaged = totalAssets();
        if (totalManaged == 0) {
            return assets;
        }

        return _mulDivUp(assets, supply, totalManaged);
    }

    /**
     * @dev Withdraws `assets` for `receiver` and burns the required shares from `owner`
     */
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {
        require(receiver != address(0), "ERC4626: withdraw to zero address");
        require(assets > 0, "ERC4626: assets must be greater than zero");

        shares = previewWithdraw(assets);
        require(shares > 0, "ERC4626: shares is zero");

        if (owner != msg.sender) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _transferAssets(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /**
     * @dev Returns the maximum amount of shares that can be redeemed by `owner`
     */
    function maxRedeem(address owner) public view override returns (uint256) {
        return balanceOf(owner);
    }

    /**
     * @dev Returns the amount of assets that would be received by redeeming `shares`
     */
    function previewRedeem(uint256 shares) public view override returns (uint256) {
        return convertToAssets(shares);
    }

    /**
     * @dev Redeems `shares` from `owner` and sends the corresponding assets to `receiver`
     */
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256 assets) {
        require(receiver != address(0), "ERC4626: redeem to zero address");
        require(shares > 0, "ERC4626: shares must be greater than zero");

        assets = previewRedeem(shares);
        require(assets > 0, "ERC4626: assets is zero");

        if (owner != msg.sender) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _transferAssets(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /**
     * @dev Internal function to transfer shares between addresses
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC4626: transfer from zero address");
        require(to != address(0), "ERC4626: transfer to zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC4626: transfer amount exceeds balance");

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    /**
     * @dev Internal function to mint shares
     */
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "ERC4626: mint to zero address");

        _totalSupply += amount;
        unchecked {
            _balances[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev Internal function to burn shares
     */
    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "ERC4626: burn from zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC4626: burn amount exceeds balance");

        unchecked {
            _balances[from] = fromBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

    /**
     * @dev Internal function to approve `spender` to spend `amount` on behalf of `owner`
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC4626: approve from zero address");
        require(spender != address(0), "ERC4626: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Internal function to decrease allowance after spending
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC4626: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Internal function to transfer assets using ERC20 `transferFrom`
     */
    function _transferAssetsFrom(address from, address to, uint256 amount) internal {
        bool success = _asset.transferFrom(from, to, amount);
        require(success, "ERC4626: transferFrom failed");
    }

    /**
     * @dev Internal function to transfer assets using ERC20 `transfer`
     */
    function _transferAssets(address to, uint256 amount) internal {
        bool success = _asset.transfer(to, amount);
        require(success, "ERC4626: transfer failed");
    }

    /**
     * @dev Helper function for multiplication and division with rounding up
     */
    function _mulDivUp(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        require(denominator != 0, "ERC4626: division by zero");
        uint256 product = x * y;
        if (x != 0 && product / x != y) {
            revert("ERC4626: multiplication overflow");
        }

        result = product / denominator;
        if (product % denominator != 0) {
            result += 1;
        }
    }
}
