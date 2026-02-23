// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6909} from "../../shared/interfaces/IERC6909.sol";
import {IERC165} from "../../shared/interfaces/IERC165.sol";

/**
 * @title ERC6909
 * @dev Implementation of the ERC6909 Minimal Multi-Token Standard
 * @notice This is a compliant ERC6909 token implementation
 */
contract ERC6909 is IERC6909 {
    mapping(address => mapping(uint256 => uint256)) public balanceOf;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public allowance;
    mapping(address => mapping(address => bool)) public isOperator;

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == type(IERC6909).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function approve(address spender, uint256 id, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender][id] = amount;
        emit Approval(msg.sender, spender, id, amount);
        return true;
    }

    function setOperator(address spender, bool approved) public virtual returns (bool) {
        isOperator[msg.sender][spender] = approved;
        emit OperatorSet(msg.sender, spender, approved);
        return true;
    }

    function transfer(address receiver, uint256 id, uint256 amount) public virtual returns (bool) {
        require(receiver != address(0), "ERC6909: transfer to zero address");
        
        uint256 senderBalance = balanceOf[msg.sender][id];
        require(senderBalance >= amount, "ERC6909: insufficient balance");

        unchecked {
            balanceOf[msg.sender][id] = senderBalance - amount;
            balanceOf[receiver][id] += amount;
        }

        emit Transfer(msg.sender, msg.sender, receiver, id, amount);
        return true;
    }

    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) public virtual returns (bool) {
        require(receiver != address(0), "ERC6909: transfer to zero address");
        require(sender != address(0), "ERC6909: transfer from zero address");

        uint256 senderBalance = balanceOf[sender][id];
        require(senderBalance >= amount, "ERC6909: insufficient balance");

        if (msg.sender != sender && !isOperator[sender][msg.sender]) {
            uint256 callerAllowance = allowance[sender][msg.sender][id];
            require(callerAllowance >= amount, "ERC6909: insufficient allowance");
            if (callerAllowance != type(uint256).max) {
                allowance[sender][msg.sender][id] = callerAllowance - amount;
            }
        }

        unchecked {
            balanceOf[sender][id] = senderBalance - amount;
            balanceOf[receiver][id] += amount;
        }

        emit Transfer(msg.sender, sender, receiver, id, amount);
        return true;
    }

    function _mint(address receiver, uint256 id, uint256 amount) internal virtual {
        require(receiver != address(0), "ERC6909: mint to zero address");

        unchecked {
            balanceOf[receiver][id] += amount;
        }

        emit Transfer(msg.sender, address(0), receiver, id, amount);
    }

    function _burn(address sender, uint256 id, uint256 amount) internal virtual {
        require(sender != address(0), "ERC6909: burn from zero address");

        uint256 senderBalance = balanceOf[sender][id];
        require(senderBalance >= amount, "ERC6909: burn amount exceeds balance");

        unchecked {
            balanceOf[sender][id] = senderBalance - amount;
        }

        emit Transfer(msg.sender, sender, address(0), id, amount);
    }
}
