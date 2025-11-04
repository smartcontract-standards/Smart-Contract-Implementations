// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC8004} from "../../shared/interfaces/IERC8004.sol";

/**
 * @title ERC8004
 * @dev Implementation of the ERC8004 Trustless Agents standard
 * @notice This is a fully compliant ERC8004 implementation following EIP-8004
 * @custom:security-contact This contract should be audited before use in production
 */
contract ERC8004 is IERC8004 {
    // Agent metadata mapping: agent => metadata URI
    mapping(address => string) private _agentMetadata;

    // Agent reputation mapping: agent => reputation score
    mapping(address => uint256) private _reputations;

    // Agent registration mapping: agent => registered status
    mapping(address => bool) private _registeredAgents;

    // Validation mapping: agent => validator => validated
    mapping(address => mapping(address => bool)) private _validations;

    // Validation count mapping: agent => count
    mapping(address => uint256) private _validationCounts;

    /**
     * @dev Creates an ERC8004 registry contract
     */
    constructor() {}

    /**
     * @dev Registers an agent with metadata
     * @param metadata URI containing agent metadata
     */
    function registerAgent(string memory metadata) public virtual override {
        require(bytes(metadata).length > 0, "ERC8004: metadata cannot be empty");
        require(!_registeredAgents[msg.sender], "ERC8004: agent already registered");

        _registeredAgents[msg.sender] = true;
        _agentMetadata[msg.sender] = metadata;
        _reputations[msg.sender] = 0;

        emit AgentRegistered(msg.sender, metadata);
    }

    /**
     * @dev Returns the metadata URI for an agent
     * @param agent The address of the agent
     * @return metadata The metadata URI
     */
    function getAgentMetadata(address agent) public view virtual override returns (string memory) {
        require(_registeredAgents[agent], "ERC8004: agent not registered");
        return _agentMetadata[agent];
    }

    /**
     * @dev Returns the reputation score for an agent
     * @param agent The address of the agent
     * @return reputation The reputation score
     */
    function getReputation(address agent) public view virtual override returns (uint256) {
        require(_registeredAgents[agent], "ERC8004: agent not registered");
        return _reputations[agent];
    }

    /**
     * @dev Updates the reputation score for an agent
     * @param agent The address of the agent
     * @param reputation The new reputation score
     */
    function updateReputation(address agent, uint256 reputation) public virtual override {
        require(_registeredAgents[agent], "ERC8004: agent not registered");

        _reputations[agent] = reputation;
        emit ReputationUpdated(agent, reputation);
    }

    /**
     * @dev Validates an agent
     * @param agent The address of the agent to validate
     */
    function validateAgent(address agent) public virtual override {
        require(_registeredAgents[agent], "ERC8004: agent not registered");
        require(agent != msg.sender, "ERC8004: cannot validate self");
        require(!_validations[agent][msg.sender], "ERC8004: already validated");

        _validations[agent][msg.sender] = true;
        unchecked {
            _validationCounts[agent] += 1;
        }

        emit AgentValidated(agent, msg.sender);
    }

    /**
     * @dev Revokes validation of an agent
     * @param agent The address of the agent to revoke validation from
     */
    function revokeValidation(address agent) public virtual override {
        require(_validations[agent][msg.sender], "ERC8004: not validated by caller");

        _validations[agent][msg.sender] = false;
        unchecked {
            _validationCounts[agent] -= 1;
        }

        emit ValidationRevoked(agent, msg.sender);
    }

    /**
     * @dev Returns whether an agent is validated by a validator
     * @param agent The address of the agent
     * @param validator The address of the validator
     * @return isValidated True if the agent is validated by the validator
     */
    function isValidated(address agent, address validator) public view virtual override returns (bool) {
        return _validations[agent][validator];
    }

    /**
     * @dev Returns the number of validations an agent has received
     * @param agent The address of the agent
     * @return count The number of validations
     */
    function getValidationCount(address agent) public view virtual override returns (uint256) {
        require(_registeredAgents[agent], "ERC8004: agent not registered");
        return _validationCounts[agent];
    }

    /**
     * @dev Returns whether an agent is registered
     * @param agent The address of the agent
     * @return isRegistered True if the agent is registered
     */
    function isRegistered(address agent) public view virtual override returns (bool) {
        return _registeredAgents[agent];
    }
}
