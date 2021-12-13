//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./Owned.sol";


/// @title Voting contract with collection and delegation functions
/// @author Kamil Khadeyev
contract Voting is Owned {
    uint public minimumQuorum;
    uint public debatingPeriod;
    //address Voter;
    uint voteCount;

    //mapping(address => Voter) public voters;
    Proposal[] public proposals;

     // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyMembers {
        require(memberId[msg.sender] != 0);
        _;
    }

   constructor(bytes32[] memory proposalNames) {

    }

    /// Deposite of tokens - #1
    function deposite (address voter) external {

    }

    /// Give Rights to voting to
    /// @param voter.
    function giveRights (address voter) external {
        
    }

    /// Delegate your vote to the voter 
    /// @param to.
    function delegate(address to) external {
    }    

    /// Send proposal for making voting
    /// param description.
    function makeVoting () external {

    }

    /// Give your vote (including votes delegated to you)
    /// to @param proposal `proposals[proposal].name`.
    function vote(uint proposal) external {
} 
