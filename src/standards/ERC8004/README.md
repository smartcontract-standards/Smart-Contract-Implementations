# ERC8004 Implementation

A comprehensive, modular implementation of the ERC-8004 Trustless Agents standard following EIP-8004.

## 📋 Overview

This implementation provides a fully compliant ERC8004 registry for discovering agents and establishing trust through reputation and validation:

- **Agent Registration**: Register agents with metadata URIs
- **Reputation System**: Track and update agent reputation scores
- **Validation Mechanism**: Validators can validate agents and build trust networks
- **Query Functions**: Check registration status, reputation, and validation counts
- **Events**: Emit events for all major operations
- **Gas Optimized**: Uses `unchecked` blocks where safe for gas efficiency

## 📁 Files

- **ERC8004.sol**: Main production ERC8004 implementation
- **ERC8004Testable.sol**: Testable version for testing (optional)
- **Test**: Comprehensive test suite covering all functionality

## 🚀 Usage

### Deployment

Deploy using the included script:

```bash
forge script script/ERC8004Deploy.s.sol:ERC8004Deploy --rpc-url <RPC_URL> --private-key <KEY> --broadcast
```

Or deploy directly:

```solidity
import {ERC8004} from "src/standards/ERC8004/ERC8004.sol";

ERC8004 registry = new ERC8004();
```

### Basic Operations

```solidity
// Register an agent
registry.registerAgent("https://api.example.com/agent/metadata");

// Get agent metadata
string memory metadata = registry.getAgentMetadata(agentAddress);

// Check if agent is registered
bool registered = registry.isRegistered(agentAddress);

// Update reputation
registry.updateReputation(agentAddress, 100);

// Get reputation
uint256 reputation = registry.getReputation(agentAddress);

// Validate an agent
registry.validateAgent(agentAddress);

// Revoke validation
registry.revokeValidation(agentAddress);

// Check if agent is validated by a validator
bool validated = registry.isValidated(agentAddress, validatorAddress);

// Get validation count
uint256 count = registry.getValidationCount(agentAddress);
```

## ✅ Test Coverage

The implementation includes comprehensive test coverage:

### Registration Tests
- ✅ Successful registration
- ✅ Emits AgentRegistered event
- ✅ Reverts when metadata is empty
- ✅ Reverts when already registered
- ✅ Supports multiple agent registrations

### Metadata Tests
- ✅ Returns correct metadata
- ✅ Reverts when agent not registered

### Reputation Tests
- ✅ Returns zero by default
- ✅ Updates reputation correctly
- ✅ Emits ReputationUpdated event
- ✅ Reverts when agent not registered
- ✅ Supports multiple reputation updates

### Validation Tests
- ✅ Successful validation
- ✅ Emits AgentValidated event
- ✅ Reverts when agent not registered
- ✅ Reverts when validating self
- ✅ Reverts when already validated
- ✅ Supports multiple validators

### Revoke Validation Tests
- ✅ Successful revocation
- ✅ Emits ValidationRevoked event
- ✅ Reverts when not validated
- ✅ Supports partial revocation

### Query Tests
- ✅ isRegistered returns correct values
- ✅ isValidated returns correct values
- ✅ getValidationCount returns correct counts
- ✅ All functions handle edge cases

### Edge Case Tests
- ✅ Validate, revoke, validate again
- ✅ Multiple agents with validations
- ✅ Reputation and validation are independent

## 🔒 Security Features

- ✅ Input validation on all functions
- ✅ Registration checks before operations
- ✅ Self-validation prevention
- ✅ Duplicate validation prevention
- ✅ Safe arithmetic with `unchecked` blocks where appropriate
- ✅ No known vulnerabilities

## 📊 Gas Optimization

The implementation uses several gas optimization techniques:

- **Unchecked arithmetic**: Used for increments/decrements where overflow/underflow is impossible
- **Efficient storage layout**: Optimized mapping structure
- **Minimal storage reads**: Cache values when used multiple times
- **Early returns**: Return values efficiently

## 🧪 Running Tests

```bash
# Run all ERC8004 tests
forge test --match-path test/standards/ERC8004/ERC8004.t.sol

# Run with verbosity
forge test --match-path test/standards/ERC8004/ERC8004.t.sol -vv

# Run with gas report
forge test --match-path test/standards/ERC8004/ERC8004.t.sol --gas-report
```

## 📚 Resources

- [EIP-8004 Specification](https://eips.ethereum.org/EIPS/eip-8004)
- [Foundry Documentation](https://book.getfoundry.sh/)

## ⚠️ Disclaimer

**DO NOT deploy to mainnet without a comprehensive security audit.** This code is provided for educational and reference purposes only.

## 📝 Notes

- Agents must register themselves (msg.sender is used)
- Reputation can be updated by anyone (may want to add access control for production)
- Validation allows any address to validate any registered agent
- Multiple validators can validate the same agent
- Validators can revoke their own validations
