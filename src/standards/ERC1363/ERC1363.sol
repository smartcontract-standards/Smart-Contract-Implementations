// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../ERC20/ERC20.sol";
import {IERC1363} from "../../shared/interfaces/IERC1363.sol";
import {IERC1363Receiver} from "../../shared/interfaces/IERC1363Receiver.sol";
import {IERC1363Spender} from "../../shared/interfaces/IERC1363Spender.sol";
import {IERC165} from "../../shared/interfaces/IERC165.sol";

/**
 * @title ERC1363
 * @dev Implementation of ERC-1363 Payable Token standard
 * @notice Extends ERC20 with transfer/approve callbacks in a single transaction
 * @custom:security-contact This contract should be audited before use in production
 */
contract ERC1363 is ERC20, IERC1363 {
    bytes4 private constant _TRANSFER_RECEIVED = IERC1363Receiver.onTransferReceived.selector;
    bytes4 private constant _APPROVAL_RECEIVED = IERC1363Spender.onApprovalReceived.selector;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_)
        ERC20(name_, symbol_, decimals_, totalSupply_)
    {}

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC1363).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function transferAndCall(address to, uint256 value) public virtual override returns (bool) {
        return transferAndCall(to, value, "");
    }

    function transferAndCall(address to, uint256 value, bytes memory data) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        _checkAndCallTransferReceived(owner, owner, to, value, data);
        return true;
    }

    function transferFromAndCall(address from, address to, uint256 value) public virtual override returns (bool) {
        return transferFromAndCall(from, to, value, "");
    }

    function transferFromAndCall(address from, address to, uint256 value, bytes memory data)
        public
        virtual
        override
        returns (bool)
    {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        _checkAndCallTransferReceived(spender, from, to, value, data);
        return true;
    }

    function approveAndCall(address spender, uint256 value) public virtual override returns (bool) {
        return approveAndCall(spender, value, "");
    }

    function approveAndCall(address spender, uint256 value, bytes memory data) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        _checkAndCallApprovalReceived(owner, spender, value, data);
        return true;
    }

    function _checkAndCallTransferReceived(address operator, address from, address to, uint256 value, bytes memory data)
        internal
    {
        require(to.code.length > 0, "ERC1363: receiver is not contract");
        bytes4 retval = IERC1363Receiver(to).onTransferReceived(operator, from, value, data);
        require(retval == _TRANSFER_RECEIVED, "ERC1363: invalid receiver return");
    }

    function _checkAndCallApprovalReceived(address owner, address spender, uint256 value, bytes memory data) internal {
        require(spender.code.length > 0, "ERC1363: spender is not contract");
        bytes4 retval = IERC1363Spender(spender).onApprovalReceived(owner, value, data);
        require(retval == _APPROVAL_RECEIVED, "ERC1363: invalid spender return");
    }
}
