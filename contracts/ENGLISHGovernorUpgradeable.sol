// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ENGLISHGovernorUpgradeable
/// @notice Enterprise-grade upgradable governance contract with Certik-style best practices

// Upgradeable contracts
import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";

// Non-upgradeable (for external use only)
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract ENGLISHGovernorUpgradeable is
    Initializable,
    GovernorSettingsUpgradeable,
    GovernorVotesUpgradeable,
    GovernorTimelockControlUpgradeable,
    GovernorVotesQuorumFractionUpgradeable
{
    /// @notice Events for parameter updates
    event VotingDelayUpdated(uint256 oldDelay, uint256 newDelay);
    event VotingPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);
    event ProposalThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);

    /// @notice Initializes the governor contract
    /// @param _token IVotes token address
    /// @param _timelock TimelockController address
    /// @param _votingDelay Voting delay in blocks
    /// @param _votingPeriod Voting period in blocks
    /// @param _proposalThreshold Minimum votes to create a proposal
    function initialize(
        IVotesUpgradeable _token,
        TimelockControllerUpgradeable _timelock,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold
    ) public initializer {
        __Governor_init("ENGLISHGovernorUpgradeable");
        __GovernorSettings_init(_votingDelay, _votingPeriod, _proposalThreshold);
        __GovernorVotes_init(_token);
        __GovernorTimelockControl_init(_timelock);
        __GovernorVotesQuorumFraction_init(4); // 4% quorum
    }

    /// @notice Override voting delay with multiple inheritance
    function votingDelay() public view override(GovernorSettingsUpgradeable, GovernorUpgradeable) returns (uint256) {
        return super.votingDelay();
    }

    /// @notice Override voting period with multiple inheritance
    function votingPeriod() public view override(GovernorSettingsUpgradeable, GovernorUpgradeable) returns (uint256) {
        return super.votingPeriod();
    }

    /// @notice Override proposal threshold with multiple inheritance
    function proposalThreshold() public view override(GovernorSettingsUpgradeable, GovernorUpgradeable) returns (uint256) {
        return super.proposalThreshold();
    }

    /// @notice Sets a new voting delay and emits an event
    function setVotingDelay(uint256 newVotingDelay) external onlyGovernance {
        require(newVotingDelay != votingDelay(), "VotingDelay unchanged");
        uint256 oldDelay = votingDelay();
        _setVotingDelay(newVotingDelay);
        emit VotingDelayUpdated(oldDelay, newVotingDelay);
    }

    /// @notice Sets a new voting period and emits an event
    function setVotingPeriod(uint256 newVotingPeriod) external onlyGovernance {
        require(newVotingPeriod != votingPeriod(), "VotingPeriod unchanged");
        uint256 oldPeriod = votingPeriod();
        _setVotingPeriod(newVotingPeriod);
        emit VotingPeriodUpdated(oldPeriod, newVotingPeriod);
    }

    /// @notice Sets a new proposal threshold and emits an event
    function setProposalThreshold(uint256 newProposalThreshold) external onlyGovernance {
        require(newProposalThreshold != proposalThreshold(), "ProposalThreshold unchanged");
        uint256 oldThreshold = proposalThreshold();
        _setProposalThreshold(newProposalThreshold);
        emit ProposalThresholdUpdated(oldThreshold, newProposalThreshold);
    }

    /// @notice Quorum override uses GovernorVotesQuorumFractionUpgradeable logic
    function quorum(uint256 blockNumber)
        public
        view
        override(GovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    /// @notice Override executor for timelock
    function _executor() internal view override(GovernorTimelockControlUpgradeable, GovernorUpgradeable) returns (address) {
        return super._executor();
    }

    /// @notice Support interface override
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Override _execute to correctly resolve multiple inheritance
    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    /// @notice Override _cancel to resolve multiple inheritance
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    /// @notice Override _queueOperations for timelock integration
    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /// @notice Storage gap for upgradeable safety
    uint256[50] private __gap;
}
