// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC8004} from "../../../src/standards/ERC8004/ERC8004.sol";

contract ERC8004Test is Test {
    ERC8004 public registry;

    string constant METADATA1 = "https://api.example.com/agent/1";
    string constant METADATA2 = "https://api.example.com/agent/2";

    address public agent1 = address(0x1);
    address public agent2 = address(0x2);
    address public validator1 = address(0x3);
    address public validator2 = address(0x4);

    event AgentRegistered(address indexed agent, string metadata);
    event ReputationUpdated(address indexed agent, uint256 reputation);
    event AgentValidated(address indexed agent, address indexed validator);
    event ValidationRevoked(address indexed agent, address indexed validator);

    function setUp() public {
        registry = new ERC8004();
    }

    // ===== Registration Tests =====

    function test_RegisterAgent_Success() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        assertTrue(registry.isRegistered(agent1), "Agent should be registered");
        assertEq(registry.getAgentMetadata(agent1), METADATA1, "Metadata should match");
        assertEq(registry.getReputation(agent1), 0, "Initial reputation should be 0");
    }

    function test_RegisterAgent_EmitsEvent() public {
        vm.prank(agent1);
        vm.expectEmit(true, false, false, true);
        emit AgentRegistered(agent1, METADATA1);

        registry.registerAgent(METADATA1);
    }

    function test_RegisterAgent_RevertsWhenEmptyMetadata() public {
        vm.prank(agent1);
        vm.expectRevert("ERC8004: metadata cannot be empty");
        registry.registerAgent("");
    }

    function test_RegisterAgent_RevertsWhenAlreadyRegistered() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(agent1);
        vm.expectRevert("ERC8004: agent already registered");
        registry.registerAgent(METADATA2);
    }

    function test_RegisterAgent_MultipleAgents() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(agent2);
        registry.registerAgent(METADATA2);

        assertTrue(registry.isRegistered(agent1), "Agent1 should be registered");
        assertTrue(registry.isRegistered(agent2), "Agent2 should be registered");
        assertEq(registry.getAgentMetadata(agent1), METADATA1, "Agent1 metadata should match");
        assertEq(registry.getAgentMetadata(agent2), METADATA2, "Agent2 metadata should match");
    }

    // ===== Metadata Tests =====

    function test_GetAgentMetadata_Success() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        assertEq(registry.getAgentMetadata(agent1), METADATA1, "Metadata should match");
    }

    function test_GetAgentMetadata_RevertsWhenNotRegistered() public {
        vm.expectRevert("ERC8004: agent not registered");
        registry.getAgentMetadata(agent1);
    }

    // ===== Reputation Tests =====

    function test_GetReputation_ReturnsZeroByDefault() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        assertEq(registry.getReputation(agent1), 0, "Reputation should be 0");
    }

    function test_GetReputation_RevertsWhenNotRegistered() public {
        vm.expectRevert("ERC8004: agent not registered");
        registry.getReputation(agent1);
    }

    function test_UpdateReputation_Success() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        registry.updateReputation(agent1, 100);

        assertEq(registry.getReputation(agent1), 100, "Reputation should be updated");
    }

    function test_UpdateReputation_EmitsEvent() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.expectEmit(true, false, false, true);
        emit ReputationUpdated(agent1, 100);

        registry.updateReputation(agent1, 100);
    }

    function test_UpdateReputation_RevertsWhenNotRegistered() public {
        vm.expectRevert("ERC8004: agent not registered");
        registry.updateReputation(agent1, 100);
    }

    function test_UpdateReputation_CanUpdateMultipleTimes() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        registry.updateReputation(agent1, 50);
        assertEq(registry.getReputation(agent1), 50, "Reputation should be 50");

        registry.updateReputation(agent1, 150);
        assertEq(registry.getReputation(agent1), 150, "Reputation should be 150");
    }

    // ===== Validation Tests =====

    function test_ValidateAgent_Success() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        assertTrue(registry.isValidated(agent1, validator1), "Agent should be validated");
        assertEq(registry.getValidationCount(agent1), 1, "Validation count should be 1");
    }

    function test_ValidateAgent_EmitsEvent() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        vm.expectEmit(true, true, false, false);
        emit AgentValidated(agent1, validator1);

        registry.validateAgent(agent1);
    }

    function test_ValidateAgent_RevertsWhenNotRegistered() public {
        vm.prank(validator1);
        vm.expectRevert("ERC8004: agent not registered");
        registry.validateAgent(agent1);
    }

    function test_ValidateAgent_RevertsWhenValidatingSelf() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(agent1);
        vm.expectRevert("ERC8004: cannot validate self");
        registry.validateAgent(agent1);
    }

    function test_ValidateAgent_RevertsWhenAlreadyValidated() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        vm.prank(validator1);
        vm.expectRevert("ERC8004: already validated");
        registry.validateAgent(agent1);
    }

    function test_ValidateAgent_MultipleValidators() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        vm.prank(validator2);
        registry.validateAgent(agent1);

        assertTrue(registry.isValidated(agent1, validator1), "Agent should be validated by validator1");
        assertTrue(registry.isValidated(agent1, validator2), "Agent should be validated by validator2");
        assertEq(registry.getValidationCount(agent1), 2, "Validation count should be 2");
    }

    // ===== Revoke Validation Tests =====

    function test_RevokeValidation_Success() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        vm.prank(validator1);
        registry.revokeValidation(agent1);

        assertFalse(registry.isValidated(agent1, validator1), "Agent should not be validated");
        assertEq(registry.getValidationCount(agent1), 0, "Validation count should be 0");
    }

    function test_RevokeValidation_EmitsEvent() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        vm.prank(validator1);
        vm.expectEmit(true, true, false, false);
        emit ValidationRevoked(agent1, validator1);

        registry.revokeValidation(agent1);
    }

    function test_RevokeValidation_RevertsWhenNotValidated() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        vm.expectRevert("ERC8004: not validated by caller");
        registry.revokeValidation(agent1);
    }

    function test_RevokeValidation_PartialRevoke() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        vm.prank(validator2);
        registry.validateAgent(agent1);

        vm.prank(validator1);
        registry.revokeValidation(agent1);

        assertFalse(registry.isValidated(agent1, validator1), "Agent should not be validated by validator1");
        assertTrue(registry.isValidated(agent1, validator2), "Agent should still be validated by validator2");
        assertEq(registry.getValidationCount(agent1), 1, "Validation count should be 1");
    }

    // ===== IsValidated Tests =====

    function test_IsValidated_ReturnsFalseByDefault() public view {
        assertFalse(registry.isValidated(agent1, validator1), "Should return false by default");
    }

    function test_IsValidated_ReturnsTrueAfterValidation() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);

        assertTrue(registry.isValidated(agent1, validator1), "Should return true after validation");
    }

    // ===== GetValidationCount Tests =====

    function test_GetValidationCount_ReturnsZeroByDefault() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        assertEq(registry.getValidationCount(agent1), 0, "Validation count should be 0");
    }

    function test_GetValidationCount_RevertsWhenNotRegistered() public {
        vm.expectRevert("ERC8004: agent not registered");
        registry.getValidationCount(agent1);
    }

    function test_GetValidationCount_IncrementsCorrectly() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);
        assertEq(registry.getValidationCount(agent1), 1, "Validation count should be 1");

        vm.prank(validator2);
        registry.validateAgent(agent1);
        assertEq(registry.getValidationCount(agent1), 2, "Validation count should be 2");
    }

    // ===== IsRegistered Tests =====

    function test_IsRegistered_ReturnsFalseByDefault() public view {
        assertFalse(registry.isRegistered(agent1), "Should return false by default");
    }

    function test_IsRegistered_ReturnsTrueAfterRegistration() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        assertTrue(registry.isRegistered(agent1), "Should return true after registration");
    }

    // ===== Edge Case Tests =====

    function test_ValidateThenRevokeThenValidateAgain() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(validator1);
        registry.validateAgent(agent1);
        assertEq(registry.getValidationCount(agent1), 1, "Validation count should be 1");

        vm.prank(validator1);
        registry.revokeValidation(agent1);
        assertEq(registry.getValidationCount(agent1), 0, "Validation count should be 0");

        vm.prank(validator1);
        registry.validateAgent(agent1);
        assertEq(registry.getValidationCount(agent1), 1, "Validation count should be 1 again");
    }

    function test_MultipleAgentsWithValidations() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        vm.prank(agent2);
        registry.registerAgent(METADATA2);

        vm.prank(validator1);
        registry.validateAgent(agent1);
        registry.validateAgent(agent2);

        vm.prank(validator2);
        registry.validateAgent(agent1);

        assertEq(registry.getValidationCount(agent1), 2, "Agent1 should have 2 validations");
        assertEq(registry.getValidationCount(agent2), 1, "Agent2 should have 1 validation");
    }

    function test_ReputationAndValidationIndependent() public {
        vm.prank(agent1);
        registry.registerAgent(METADATA1);

        registry.updateReputation(agent1, 100);
        assertEq(registry.getReputation(agent1), 100, "Reputation should be 100");

        vm.prank(validator1);
        registry.validateAgent(agent1);
        assertEq(registry.getValidationCount(agent1), 1, "Validation count should be 1");
        assertEq(registry.getReputation(agent1), 100, "Reputation should still be 100");
    }
}
