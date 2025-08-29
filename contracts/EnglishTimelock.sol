// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title ENGLISHTimelock
 * @notice Enterprise-grade Timelock controller for $ENGLISH DAO governance
 * @dev Inherits OpenZeppelin TimelockController and includes parameter validation and event logging
 */
contract ENGLISHTimelock is TimelockController {

    // Event for initialization transparency
    event TimelockInitialized(
        uint256 minDelay,
        address[] proposers,
        address[] executors
    );

    /**
     * @notice Constructor sets up the Timelock controller
     * @param minDelay Delay in seconds before queued actions can be executed (e.g., 48 hours)
     * @param proposers Addresses allowed to propose actions (usually Governor contract)
     * @param executors Addresses allowed to execute actions after delay
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    )
        TimelockController(minDelay, proposers, executors)
    {
        // Validation
        require(minDelay >= 1 hours, "ENGLISHTimelock: minDelay too low");
        require(proposers.length > 0, "ENGLISHTimelock: proposers empty");
        require(executors.length > 0, "ENGLISHTimelock: executors empty");

        // Emit initialization event for transparency
        emit TimelockInitialized(minDelay, proposers, executors);
    }
}
