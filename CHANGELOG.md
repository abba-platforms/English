# Changelog

This file follows the **“Keep a Changelog”** format ([https://keepachangelog.com/](https://keepachangelog.com/)) to provide a clear, human-readable history of all notable changes to $ENGLISH MEMECOIN. It also follows **semantic versioning** to track versions and updates efficiently.

All notable changes to $ENGLISH MEMECOIN will be documented in this file.

## [1.4] – 2025-09-02

### Added

-   Deployed upgraded `ENGLISHGovernorUpgradeable.sol` smart contract with enterprise-grade governance features
-   Integration with `TimelockControllerUpgradeable` for enhanced proposal security
-   Quorum set to 4% using `GovernorVotesQuorumFractionUpgradeable`
-   Custom events for `VotingDelayUpdated`, `VotingPeriodUpdated`, `ProposalThresholdUpdated`

### Updated

-   Overridden functions for multiple inheritance resolved and aligned with OpenZeppelin upgradeable standards
-   Voting delay, voting period, and proposal threshold setter functions now emit events
-   README and documentation updated to include governance contract details

### Fixed

-   Multiple inheritance override issues from previous upgrade attempt
-   Function visibility and override specifiers corrected
-   Removed undeclared identifiers and compilation errors in Solidity 0.8.20

## [1.3] – 2025-08-30

### Added

-   Updated $ENGLISH MEMECOIN logo: `englishcoin.png` in the branding folder
-   References in README and documentation updated to reflect new logo file

### Updated

-   README displays new PNG logo instead of old JPG
-   Minor formatting improvements in README to enhance visual consistency

## [1.2] – 2025-08-29

### Added

-   Humorous tagline: "DO YOU SPEAKER AN ENGLISH?"
-   Full README with project description, tokenomics, and logo
-   Branding folder (`branding/`) with `englishcoin.jpg` logo
-   GitHub “About” summary drafted

### Updated

-   README to display `englishcoin.jpg` from branding folder
-   Tokenomics section clarified: Team 35%, Liquidity 40%, Airdrops/Community 25%

## [1.1] – 2025-08-28

### Added

-   Initial repository structure for $ENGLISH MEMECOIN
-   Token code setup and template for BNB Smart Chain (BEP-20)
-   Initial README with placeholder description and sections

### Updated

-   README improved with community-driven meme focus
-   Logo concept discussed and designed (pre-upload)

## [1.0] – 2025-08-27

### Added

-   Repository initialized
-   First commit with project skeleton
-   Planning notes for tokenomics, branding, and meme-based theme
