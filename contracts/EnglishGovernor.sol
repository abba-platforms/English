// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title ENGLISHGovernorUpgradeable
 * @notice Upgradeable governance contract for $ENGLISH DAO
 * @dev Enterprise-grade, CertiK-style audited-ready
 */
contract ENGLISHGovernorUpgradeable is
    Initializable,
    GovernorUpgradeable,
    GovernorSettingsUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorVotesUpgradeable,
    GovernorTimelockControlUpgradeable
{
    /// @notice Quorum percentage of total token supply
    uint256 private _quorumPercentage;

    /// @notice Emitted upon initialization
    event GovernorInitialized(
        uint256 votingDelay,
        uint256 votingPeriod,
        uint256 proposalThreshold,
        uint256 quorumPercentage
    );

    /**
     * @notice Initialize the Governor
     * @param _token ERC20VotesUpgradeable token
     * @param _timelock TimelockControllerUpgradeable contract
     * @param _votingDelay Delay (in blocks) before voting starts
     * @param _votingPeriod Duration (in blocks) for voting
     * @param _proposalThreshold Minimum votes required to propose
     * @param quorumPercentage Percentage of total supply required for quorum (1-100)
     */
    function initialize(
        ERC20VotesUpgradeable _token,
        TimelockControllerUpgradeable _timelock,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold,
        uint256 quorumPercentage
    ) public initializer {
        // Initialize OpenZeppelin upgradeable parent contracts
        __Governor_init("ENGLISHGovernorUpgradeable");
        __GovernorSettings_init(_votingDelay, _votingPeriod, _proposalThreshold);
        __GovernorCountingSimple_init();
        __GovernorVotes_init(_token);
        __GovernorTimelockControl_init(_timelock);

        // Parameter validation
        require(_votingDelay >= 1, "Voting delay too low");
        require(_votingPeriod >= 10, "Voting period too short");
        require(_proposalThreshold >= 1, "Proposal threshold too low");
        require(quorumPercentage > 0 && quorumPercentage <= 100, "Invalid quorum percentage");

        _quorumPercentage = quorumPercentage;

        emit GovernorInitialized(_votingDelay, _votingPeriod, _proposalThreshold, _quorumPercentage);
    }

    // ------------------------
    // Override functions
    // ------------------------

    function votingDelay() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber) public view override returns (uint256) {
        return (token.getPastTotalSupply(blockNumber) * _quorumPercentage) / 100;
    }

    function proposalThreshold() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.proposalThreshold();
    }

    // Timelock / Execution Overrides
    function state(uint256 proposalId) public view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (ProposalState) {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        public override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (address) {
        return super._executor();
    }
}
