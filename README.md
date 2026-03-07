# Smart Contract Standards - ERC Implementations

A comprehensive, modular repository of Ethereum Request for Comments (ERC) token standards implementations. This project serves as a reference and starting point for building compliant smart contracts following Ethereum's most widely adopted standards.

> ⚠️ **CRITICAL SECURITY WARNING**: **DO NOT** directly deploy these contracts to mainnet without a comprehensive security audit by qualified professionals. This code is provided for educational and reference purposes. Smart contracts deployed to Ethereum mainnet can result in irreversible loss of funds. Always:
> - **Conduct thorough audits** before any production deployment
> - **Review and test** all code carefully in your specific use case
> - **Consider engaging** professional audit firms for high-value contracts
> - **Understand** that using these contracts is at your own risk
> - **Never deploy** contracts containing real funds without proper security reviews

## 📋 Overview

This repository contains production-ready implementations of various ERC standards with a focus on:
- **Modular Architecture**: Clean separation of concerns and reusable components
- **Gas Efficiency**: Optimized implementations for cost-effective deployment and execution
- **Security Best Practices**: Following established security patterns and standards
- **Test Coverage**: Comprehensive test suites for each implementation
- **Documentation**: Clear documentation and usage examples

## 🏗️ Repository Structure

```
ERC/
├── src/                      # Source contracts
│   ├── standards/           # ERC standard implementations
│   │   ├── ERC20/          # Fungible tokens
│   │   ├── ERC721/         # Non-fungible tokens
│   │   ├── ERC1155/        # Multi-token standard
│   │   ├── ERC2612/        # ERC20 Permit (gasless approvals)
│   │   ├── ERC2981/        # NFT Royalty (ERC721/ERC1155)
│   │   ├── ERC4907/        # Rental NFT (user/expires)
│   │   ├── ERC5192/        # Soulbound NFTs
│   │   ├── ERC8004/        # Trustless Agents
│   │   ├── ERC165/         # Standard Interface Detection
│   │   ├── ERC1271/        # Standard Signature Validation
│   │   ├── ERC3156/        # Flash Loans
│   │   └── ...
│   └── shared/             # Shared components and utilities
│       ├── interfaces/     # Interface definitions
│       ├── libraries/      # Reusable libraries
│       └── extensions/     # Standard extensions
├── test/                    # Test files
│   ├── standards/
│   └── integration/
├── script/                  # Deployment scripts
└── docs/                    # Additional documentation
```

## 🎯 Implemented Standards

This repository aims to implement a comprehensive collection of ERC standards across various categories:

### 🔴 Core Token Standards
- **ERC-20**: Fungible Token Standard ✅ *complete* - [View Implementation](src/standards/ERC20/) - [Read Docs](src/standards/ERC20/README.md)
- **ERC-721**: Non-Fungible Token Standard ✅ *complete* - [View Implementation](src/standards/ERC721/) - [Read Docs](src/standards/ERC721/README.md)
- **ERC-1155**: Multi Token Standard ✅ *complete* - [View Implementation](src/standards/ERC1155/) - [Read Docs](src/standards/ERC1155/README.md)
- **ERC-4626**: Tokenized Vault Standard ✅ *complete* - [View Implementation](src/standards/ERC4626/) - [Read Docs](src/standards/ERC4626/README.md)
- **ERC-6909**: Minimal Multi-Token Standard ✅ *complete* - [View Implementation](src/standards/ERC6909/) - [Read Docs](src/standards/ERC6909/README.md)
- **ERC-7540**: Minimal Multi-Token Standard (Alternative) 📋 *planned*
- **ERC-7521**: Intents Token Standard 📋 *planned*

### 🔵 Interface & Detection Standards
- **ERC-165**: Standard Interface Detection ✅ *complete* - [View Implementation](src/standards/ERC165/) - [Read Docs](src/standards/ERC165/README.md)
- **ERC-1820**: Pseudo-introspection Registry 📋 *planned*
- **ERC-6821**: Singleton Factory ⏳ *in progress*

### 🟢 Metadata & Information Standards
- **ERC-20**: Token Metadata (Name, Symbol, Decimals)
- **ERC-721**: NFT Metadata Extensions
- **ERC-1155**: Multi-Token Metadata
- **ERC-2309**: Consecutive Transfer Standard 📋 *planned*

### 🟡 Permission & Authorization Standards
- **ERC-2612**: Permit Extension for ERC-20 ✅ *complete* - [View Implementation](src/standards/ERC2612/) - [Read Docs](src/standards/ERC2612/README.md)
- **ERC-777**: Advanced Token Standard 📋 *planned*
- **ERC-725**: General Key-Value Store / Identity 📋 *planned*
- **ERC-1056**: Ethereum Light Client Identity 📋 *planned*
- **ERC-7568**: Token State Fingerprinting 📋 *planned*

### 🟠 Royalty & Payment Standards
- **ERC-2981**: NFT Royalty Standard ✅ *complete* - [View Implementation](src/standards/ERC2981/) - [Read Docs](src/standards/ERC2981/README.md)
- **ERC-5501**: EIP-165 Interface Support for ERC-2981 📋 *planned*
- **ERC-5727**: Expandable Vesting NFT 📋 *planned*
- **ERC-5215**: EIP-721 Enumerable ⏳ *in progress*
- **ERC-7007**: ZK EdDSA Verifier Registry ⏳ *in progress*

### 🟣 Transfer & Accounting Standards
- **ERC-3156**: Flash Loans ✅ *complete* - [View Implementation](src/standards/ERC3156/) - [Read Docs](src/standards/ERC3156/README.md)
- **ERC-1363**: Payable Token 📋 *planned*
- **ERC-3525**: Semi-Fungible Token Standard 📋 *planned*
- **ERC-3589**: Proxy ERC20 ⏳ *in progress*

### 🔶 Governance & Voting Standards
- **ERC-1400**: Security Token Standard 📋 *planned*
- **ERC-5192**: Minimal Soulbound NFTs ✅ *complete* - [View Implementation](src/standards/ERC5192/) - [Read Docs](src/standards/ERC5192/README.md)
- **ERC-5750**: General Extensibility for Method-Based Programmable NFTs 📋 *planned*

### 🔷 Utility & Extension Standards
- **ERC-1812**: Ethereum Name Service Reverse Resolution 📋 *planned*
- **ERC-3056**: Unvested Token Standard 📋 *planned*
- **ERC-3664**: CCIP Read: Secure Offchain Data Retrieval 📋 *planned*
- **ERC-4519**: NFT Descriptor 🏃 *WIP*
- **ERC-4907**: Rental NFT, EIP-721 User And Expires ✅ *complete* - [View Implementation](src/standards/ERC4907/) - [Read Docs](src/standards/ERC4907/README.md)
- **ERC-5083**: RNG (Random Number Generator) Multi-Source ⏳ *in progress*
- **ERC-6949**: Token Info Event ⏳ *in progress*
- **ERC-7009**: ZK NameRegistry ⏳ *in progress*
- **ERC-7442**: Token Pauser Timestamp ⏳ *in progress*
- **ERC-7579**: Minimum Modular Smart Accounts ⏳ *in progress*
- **ERC-7587**: EIP-721 Upgradeable with Rules ⏳ *in progress*
- **ERC-7719**: Max Querier Commit Timestamp ⏳ *in progress*

### 🤖 Agent & Trust Standards
- **ERC-8004**: Trustless Agents ✅ *complete* - [View Implementation](src/standards/ERC8004/) - [Read Docs](src/standards/ERC8004/README.md)

### 🔸 Advanced & Experimental Standards
- **ERC-6909**: Minimal Multi-Token Interface (Advanced) ✅ *complete* - [View Implementation](src/standards/ERC6909/) - [Read Docs](src/standards/ERC6909/README.md)
- **ERC-7575**: Minimal Executor Interface ⏳ *in progress*
- **ERC-7616**: ZK Verifier Registry ⏳ *in progress*
- **ERC-7703**: ERC-7702 Extension for ERC-20 Tokens ⏳ *in progress*
- **ERC-7723**: Token Payment & Revenue Share 📋 *planned*
- **ERC-7904**: EIP-165 Interface Detection for EIP-20 Tokens ⏳ *in progress*

### 🔹 Wrapper & Compatibility Standards
- **ERC-1271**: Standard Signature Validation Method ✅ *complete* - [View Implementation](src/standards/ERC1271/) - [Read Docs](src/standards/ERC1271/README.md)
- **ERC-2696**: Safer ERC20 📋 *planned*
- **ERC-4804**: ENS Resolver Omnichain (LayerZero) 📋 *planned*
- **ERC-5169**: Cross-Chain Execution ⏳ *in progress*
- **ERC-6551**: Non-fungible Bound Accounts 📋 *planned*

### 🏷️ Status Legend
- ⏳ *in progress* - Currently being implemented
- 🏃 *WIP* - Work in progress
- 📋 *planned* - Queued for implementation
- ✅ *complete* - Fully implemented and tested

*This is an active repository. Standards are continuously added based on community needs and EIP finalization.*

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (latest version)
- Rust (for Foundry)
- Git

### Installation

1. Clone the repository:
```bash
git clone git@github.com:smartcontract-standards/Smart-Contract-Implementations.git
cd Smart-Contract-Implementations
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

## 🛠️ Usage

### Building

Compile all contracts:
```bash
forge build
```

### Testing

Run all tests:
```bash
forge test
```

Run tests with gas reporting:
```bash
forge test --gas-report
```

Run tests with verbosity:
```bash
forge test -vvv
```

Run specific test file:
```bash
forge test --match-path test/standards/ERC20/ERC20.t.sol
```

### Formatting

Format all Solidity files:
```bash
forge fmt
```

### Gas Snapshots

Generate gas snapshots:
```bash
forge snapshot
```

Compare snapshots:
```bash
forge snapshot --diff
```

### Deployment

Deploy a contract to a network:
```bash
forge script script/<ContractName>.s.sol:ContractScript \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

## 🏗️ Development

### Adding New Standards

When implementing a new ERC standard:

1. Create a new directory under `src/standards/`
2. Implement the standard and any extensions
3. Create comprehensive tests in `test/standards/`
4. Add deployment scripts in `script/`
5. Update this README with the new standard

### Code Style

- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use `forge fmt` before committing
- Document complex logic with NatSpec comments
- Write test coverage for all functions

## 🔒 Security

### ⚠️ IMPORTANT: Auditing Required

**NEVER** use these contracts directly in production without proper auditing. This repository is intended for:
- Educational purposes and learning
- Reference implementation of ERC standards
- Starting point for custom implementations

**REQUIRED** before any production use:
- ✅ Professional security audit by reputable firms
- ✅ Thorough code review
- ✅ Comprehensive testing in testnet environments
- ✅ Understanding of all risks and attack vectors
- ✅ Proper access control and upgrade mechanisms where applicable

### Security Practices

Security is a top priority. This repository:

- Implements established security best practices
- Uses battle-tested patterns from OpenZeppelin where applicable
- Includes fuzz testing for critical functions
- Undergoes regular security audits (planned)

**⚠️ WARNING**: This code is provided "as-is" without any warranties. Smart contract bugs can result in irreversible loss of funds. Deploy at your own risk and always engage professional auditors.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Implement your changes with tests
4. Ensure all tests pass
5. Submit a pull request

## 📚 Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [EIPS](https://eips.ethereum.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Solidity Documentation](https://docs.soliditylang.org/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Foundry team for the amazing development toolkit
- Ethereum Foundation and EIP authors
- OpenZeppelin for inspiration and best practices
- The broader Ethereum community

## 📞 Contact & Support

For questions, suggestions, or support, please open an issue on GitHub.

---

**Disclaimer**: This software is provided "as is" without warranty of any kind. Use at your own risk.
