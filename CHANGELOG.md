# Changelog

This file follows the **“Keep a Changelog”** format ([https://keepachangelog.com/](https://keepachangelog.com/)) to provide a clear, human-readable history of all notable changes to $ENGLISH MEMECOIN. It also follows **semantic versioning** to track versions and updates efficiently.

All notable changes to $ENGLISH MEMECOIN will be documented in this file.

## [1.6] – 2025-09-06

### Added

- Added `BEST_OF_ENGLISH.md` to the root directory with detailed GitHub-ready description of $ENGLISH token, Meme-DAO features, and cultural NFT collectibles.
- Fully revised README to include `BEST_OF_ENGLISH.md` in repository contents and updated sections for deployment, contract info, DAO, and community features.

### Updated

- README updated to reflect current repository structure:
  - Contracts: `contracts/English.sol`
  - Documentation: `WHITEPAPER.md`, `MARKET_ANALYSIS.md`, `BEST_OF_ENGLISH.md`
  - Guidelines: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- Repository content table improved for Markdown copy-paste compatibility.
- README highlights $ENGLISH Meme-DAO tokenomics, meme-driven rewards, staking, and DAO governance.

### Fixed

- Corrected minor formatting issues in README tables and headings.
- Ensured proper linking between README and `BEST_OF_ENGLISH.md` document.

## [1.5] – 2025-09-05

### Added

- $ENGLISH token officially deployed on Binance Smart Chain (BSC) Mainnet.
- First batch of 10 billion $ENGLISH tokens minted.
- Verified contract address added: `0x5aC7E03702f4C5eDa984dB80110e8acd85b6ac42`.
- README updated with full deployment details and contract address.
- Airdrop announcement drafted for early community distribution of $ENGLISH tokens.

### Updated

- Repository cleaned: removed `EnglishGovernor.sol`, `EnglishGovernorUpgradeable.sol`, and `EnglishTimelock.sol`.
- README updated to reflect current contract structure (`English.sol`) and deployment on BSC.
- Minting function improved to allow batch minting of 10B tokens up to a max supply of 100B.
- Raw Markdown formatting in README adjusted for table and document compatibility.

### Fixed

- ERC-20 burn and burnForMeme functions confirmed working on Mainnet.
- Minor issues with allowance and transfer functions corrected.
- Resolved formatting issues in README tables for copy-paste consistency.

## [1.4] – 2025-09-02

### Added

- Deployed upgraded `ENGLISHGovernorUpgradeable.sol` smart contract with enterprise-grade governance features
- Integration with `TimelockControllerUpgradeable` for enhanced proposal security
- Quorum set to 4% using `GovernorVotesQuorumFractionUpgradeable`
- Custom events for `VotingDelayUpdated`, `VotingPeriodUpdated`, `ProposalThresholdUpdated`

### Updated

- Overridden functions for multiple inheritance resolved and aligned with OpenZeppelin upgradeable standards
- Voting delay, voting period, and proposal threshold setter functions now emit events
- README and documentation updated to include governance contract details

### Fixed

- Multiple inheritance override issues from previous upgrade attempt
- Function visibility and override specifiers corrected
- Removed undeclared identifiers and compilation errors in Solidity 0.8.20

## [1.3] – 2025-08-30

### Added

- Updated $ENGLISH MEMECOIN logo: `englishcoin.png` in the branding folder
- References in README and documentation updated to reflect new logo file

### Updated

- README displays new PNG logo instead of old JPG
- Minor formatting improvements in README to enhance visual consistency

## [1.2] – 2025-08-29

### Added

- Humorous tagline: "DO YOU SPEAKER AN ENGLISH?"
- Full README with project description, tokenomics, and logo
- Branding folder (`branding/`) with `englishcoin.jpg` logo
- GitHub “About” summary drafted

### Updated

- README to display `englishcoin.jpg` from branding folder
- Tokenomics section clarified: Team 35%, Liquidity 40%, Airdrops/Community 25%

## [1.1] – 2025-08-28

### Added

- Initial repository structure for $ENGLISH MEMECOIN
- Token code setup and template for BNB Smart Chain (BEP-20)
- Initial README with placeholder description and sections

### Updated

- README improved with community-driven meme focus
- Logo concept discussed and designed (pre-upload)

## [1.0] – 2025-08-27

### Added

- Repository initialized
- First commit with project skeleton
- Planning notes for tokenomics, branding, and meme-based theme
