// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "../../shared/interfaces/IERC165.sol";

/**
 * @title ERC165
 * @dev Implementation of the ERC-165 Standard Interface Detection
 * @notice Enables contracts to publish and detect which interfaces they implement
 * @custom:security-contact This contract should be audited before use in production
 */
abstract contract ERC165 is IERC165 {
    /// @dev Mapping of interface id to whether it is supported
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        _registerInterface(type(IERC165).interfaceId);
    }

    /**
     * @dev Registers an interface as supported
     * @param interfaceId The interface identifier (XOR of function selectors)
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
}
