// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC1155} from "../../shared/interfaces/IERC1155.sol";
import {IERC1155MetadataURI} from "../../shared/interfaces/IERC1155MetadataURI.sol";
import {IERC1155Receiver} from "../../shared/interfaces/IERC1155Receiver.sol";

/**
 * @title ERC1155
 * @dev Implementation of the ERC1155 Multi Token Standard
 * @notice This is a fully compliant ERC1155 implementation following EIP-1155
 * @custom:security-contact This contract should be audited before use in production
 */
contract ERC1155 is IERC1155, IERC1155MetadataURI {
    // Mapping from token ID to account balances: tokenId => account => balance
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals: account => operator => approved
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Base URI for token metadata
    string private _uri;

    /**
     * @dev Creates an ERC1155 token with the given base URI
     * @param uri_ Base URI for all token types
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev Returns the URI for token type `id`
     * @param id The token ID to query
     * @return uri The URI string
     */
    function uri(uint256 id) public view virtual override returns (string memory) {
        string memory baseURI = _uri;
        if (bytes(baseURI).length == 0) {
            return "";
        }
        return string(abi.encodePacked(baseURI, _toString(id)));
    }

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`
     * @param account The address to query
     * @param id The token ID to query
     * @return balance The balance of the token type
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev Returns the amount of tokens of each token type `ids` owned by `account`
     * @param accounts The addresses to query
     * @param ids The token IDs to query
     * @return balances The balances of each token type
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens
     * @param operator The address to set as operator
     * @param approved True to grant permission, false to revoke
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev Returns true if `operator` is approved to transfer `account`'s tokens
     * @param account The address to query
     * @param operator The address to query
     * @return approved True if operator is approved for all
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param id The token ID to transfer
     * @param amount The amount to transfer
     * @param data Additional data with no specified format
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
        public
        virtual
        override
    {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev Transfers `amounts` tokens of token types `ids` from `from` to `to`
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param ids The token IDs to transfer
     * @param amounts The amounts to transfer
     * @param data Additional data with no specified format
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Internal function to transfer `amount` tokens of token type `id` from `from` to `to`
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param id The token ID to transfer
     * @param amount The amount to transfer
     * @param data Additional data with no specified format
     */
    function _safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
        internal
        virtual
    {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev Internal function to transfer `amounts` tokens of token types `ids` from `from` to `to`
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param ids The token IDs to transfer
     * @param amounts The amounts to transfer
     * @param data Additional data with no specified format
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
                _balances[id][to] += amount;
            }
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Internal function to mint `amount` tokens of token type `id` to `to`
     * @param to The address to mint to
     * @param id The token ID to mint
     * @param amount The amount to mint
     * @param data Additional data with no specified format
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = msg.sender;
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev Internal function to mint `amounts` tokens of token types `ids` to `to`
     * @param to The address to mint to
     * @param ids The token IDs to mint
     * @param amounts The amounts to mint
     * @param data Additional data with no specified format
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        virtual
    {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Internal function to burn `amount` tokens of token type `id` from `from`
     * @param from The address to burn from
     * @param id The token ID to burn
     * @param amount The amount to burn
     */
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = msg.sender;
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Internal function to burn `amounts` tokens of token types `ids` from `from`
     * @param from The address to burn from
     * @param ids The token IDs to burn
     * @param amounts The amounts to burn
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Hook that is called before any token transfer
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Sets the URI for all token types
     * @param newuri The new URI string
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Internal function to check if a contract implements IERC1155Receiver
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    /**
     * @dev Internal function to check if a contract implements IERC1155Receiver for batch transfers
     */
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    /**
     * @dev Helper function to create a singleton array
     */
    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        return array;
    }

    /**
     * @dev Converts a uint256 to its ASCII string decimal representation
     */
    function _toString(uint256 value) private pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
