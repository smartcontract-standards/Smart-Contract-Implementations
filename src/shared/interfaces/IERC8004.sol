// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC8004
 * @dev Standard Interface for Trustless Agents
 * @notice See https://eips.ethereum.org/EIPS/eip-8004 for full specification
 */
interface IERC8004 {
    /**
     * @dev Emitted when an agent is registered
     * @param agent The address of the registered agent
     * @param metadata URI containing agent metadata
     */
    event AgentRegistered(address indexed agent, string metadata);

    /**
     * @dev Emitted when an agent's reputation is updated
     * @param agent The address of the agent
     * @param reputation The new reputation score
     */
    event ReputationUpdated(address indexed agent, uint256 reputation);

    /**
     * @dev Emitted when an agent is validated
     * @param agent The address of the agent
     * @param validator The address that validated the agent
     */
    event AgentValidated(address indexed agent, address indexed validator);

    /**
     * @dev Emitted when validation is revoked
     * @param agent The address of the agent
     * @param validator The address that revoked validation
     */
    event ValidationRevoked(address indexed agent, address indexed validator);

    /**
     * @dev Registers an agent with metadata
     * @param metadata URI containing agent metadata
     */
    function registerAgent(string memory metadata) external;

    /**
     * @dev Returns the metadata URI for an agent
     * @param agent The address of the agent
     * @return metadata The metadata URI
     */
    function getAgentMetadata(address agent) external view returns (string memory);

    /**
     * @dev Returns the reputation score for an agent
     * @param agent The address of the agent
     * @return reputation The reputation score
     */
    function getReputation(address agent) external view returns (uint256);

    /**
     * @dev Updates the reputation score for an agent
     * @param agent The address of the agent
     * @param reputation The new reputation score
     */
    function updateReputation(address agent, uint256 reputation) external;

    /**
     * @dev Validates an agent
     * @param agent The address of the agent to validate
     */
    function validateAgent(address agent) external;

    /**
     * @dev Revokes validation of an agent
     * @param agent The address of the agent to revoke validation from
     */
    function revokeValidation(address agent) external;

    /**
     * @dev Returns whether an agent is validated by a validator
     * @param agent The address of the agent
     * @param validator The address of the validator
     * @return isValidated True if the agent is validated by the validator
     */
    function isValidated(address agent, address validator) external view returns (bool);

    /**
     * @dev Returns the number of validations an agent has received
     * @param agent The address of the agent
     * @return count The number of validations
     */
    function getValidationCount(address agent) external view returns (uint256);

    /**
     * @dev Returns whether an agent is registered
     * @param agent The address of the agent
     * @return isRegistered True if the agent is registered
     */
    function isRegistered(address agent) external view returns (bool);
}
