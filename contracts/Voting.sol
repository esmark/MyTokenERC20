//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./Owned.sol";


/// @title Voting contract with collection and delegation functions
/// @author Kamil Khadeyev
contract Voting is Owned {
    address public tokenAddress;
    address public chairperson;
    uint256 public minimumQuorum;
    uint256 public debatingPeriod;
   
    struct Voter {
        uint balance; // token balance is stored for voting
        address delegated; // person whom sent delegated weight to
        mapping(address => uint256) delegate; // person and balance who delegate weight to
        address[] delegators; //addresses of delegators who belive you voting;
        mapping(uint256 => uint256) votedProposal; // voted Poll -> Proposal
    }

    struct Poll {
        uint256 balance; // common balance of the Poll
        address recipient; // address of contract where to send
        bytes32 description; // description of polling (up to 32 bytes)
        bytes byteCode; // signiture of the function
        uint256 createdAt; // poll created timestamp
        Proposal[] proposals; // proposals of the poll
        bool finished; // finished status of the poll: false - open, true - finished
        bytes32 winner; // winned proposal when finished, `no-winner` if haven't min quorum
    }

    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint256 votedBalance; // amount of voted tokens
    }

    mapping(address => Voter) public voters;

    Poll[] public polls;

    event Delegate(address indexed from, address indexed to, uint256 value);
    event Vote(address indexed voter, bytes32 pollDescription, bytes32 proposalName, uint256 amount);
    event StartVoting(address indexed recipient, bytes32 description, uint256 proposalCount, uint256 startedTime);
    event FinishVoting(address indexed recipient, bytes returnCalldata, bytes32 indexed winner, uint256 finishedTime);
 


    /// @dev Constructor
    constructor() {
        tokenAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
        chairperson = msg.sender;
        minimumQuorum = 30000000; //should agreed min 30%
        debatingPeriod = 3 days; //set to 3 days
    }



    /// @dev set Voting Rules by chairperson (onlyOwner)
    function setVotingRules(uint256 minimumQuorum_, uint256 debatingPeriod_) external onlyOwner {
        minimumQuorum = minimumQuorum_;
        debatingPeriod = debatingPeriod_;
    }



    /// @notice Deposite of tokens
    /// @dev Transfer the balance from token owner's account to 
    /// @param recipient account (address of receiver or smart contract). 
    /// @param amount - 0 value transfers are not allowed. Owner's account must have sufficient balance to transfer
    function deposite(address recipient, uint256 amount)  external returns (bytes memory) {
        Voter storage sender = voters[msg.sender];
        require(amount > 0, "Zero amount is not allowed");
        require(hasVotingRecipient(recipient), "Address of this voting contract not registered");

        sender.delegated == msg.sender; //you delegated youself

        // transferFrom(address,address,uint256) => 23b872dd
        (bool success, bytes memory returnData) = tokenAddress.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)", // => 23b872dd
                msg.sender,
                address(0),
                amount
            )
        );
        require(success, "Call transferFrom failed");
        sender.balance += amount;

        return returnData;
    }


    /// @notice Delegate your tokens to the voter 'to':
    /// @param to address to which balance is delegated
    /// @param weight amount of delegated tokens
    function delegate(address to, uint weight) public {
        Voter storage sender = voters[msg.sender];
        require(weight > 0, "Zero amount is not allowed");
        require(voters[to].delegate[msg.sender] <= sender.balance, "You haven't enough tokens.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (to != address(0)) {
            to = msg.sender;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.delegated = to;
        voters[to].delegate[msg.sender] = weight;
        voters[to].delegators.push(msg.sender);

        emit Delegate(msg.sender, to, weight);
    }




    /// @notice Has rights to withdraw tokens back to balance
    /// @param from.
    // redelegate
    function redelegate(address from) public {
        Voter storage sender = voters[msg.sender];
        require(sender.balance > 0, "Zero amount is not allowed");
        require(voters[from].delegate[msg.sender] <= sender.balance, "You haven't enough tokens.");
        require(from != msg.sender || sender.delegated != msg.sender, "Self-redelegation is disallowed.");

        sender.delegated = msg.sender;
        voters[from].delegate[msg.sender] = 0;

        for (uint i = 0; i < voters[from].delegators.length; i++) {
            if (voters[from].delegators[i] == msg.sender) {
                delete voters[from].delegators[i];
            }
        }

        emit Delegate(from, msg.sender, voters[from].delegate[msg.sender]);
    }


    /// @notice Withdraw of tokens and delegated balance
    /// @dev Transfer the balance amount from token owner's account to 
    /// from account (address of receiver). Owner's account must have sufficient balance to transfer
    function withdraw() external returns (bytes memory) {
        Voter storage sender = voters[msg.sender];
        // require(balanceOf(msg.sender) > sender.balance, "You haven't enough tokens.");
        require(hasWithdrawRights());

        uint256 amount = sender.balance;
        (bool success, bytes memory returnData) = tokenAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)", // => a9059cbb
                msg.sender,
                amount
            )
        );
        require(success, "Call transfer failed");
        sender.balance = 0;

        return returnData;
    }



    /// @notice Has rights to withdraw amount back
    function hasWithdrawRights() public view returns (bool) {
        Voter storage sender = voters[msg.sender];
        require(sender.delegated == msg.sender, "Firstly redelegate balance back to your address.");
        require(sender.balance > 0, "The voter should has positive balance");

        for (uint i = 0; i < polls.length; i++) {
            require((polls[i].finished == true) || (polls[i].finished == false && sender.votedProposal[i] == 0), "You haven't finished votes");
        }

        return true;
    }



    /// @notice Has registered address of voting
    /// @param recipient.
    function hasVotingRecipient(address recipient) public view returns (bool) {
        require(recipient != address(0), "Disallow transfer to 0 address");

        for (uint i = 0; i < polls.length; i++) {
            if (polls[i].recipient == recipient) {
                return true;
            }
        }

        return false;
    }



    /// @notice Has rights to vote or make a Poll
    /// @param voter.
    function hasVotingRights(address voter) public view returns (bool) {
        require(
            (voters[voter].balance > 0 && voters[voter].delegated == msg.sender), 
            "The voter should has positive balance and no delegated weight"
        );
        return true;
    }



    /// @notice Send data and proposals for making new poll
    /// @param recipient - address of contract recipient, 
    /// @param description - description of the poll, 
    /// @param byteCode - byteCode description, 
    /// @param proposalNames - array of proposal names in bytes32.
    /// @dev ToDo: bytes32 calldata byteCode
    function addPoll(address recipient, bytes32 description, bytes memory byteCode, bytes32[] memory proposalNames) external {
        require(hasVotingRights(msg.sender));
        
        uint256 pollindex = polls.length;
        polls[pollindex].recipient = recipient;
        polls[pollindex].description = description;
        polls[pollindex].byteCode = byteCode;
        uint256 proposalCount = proposalNames.length;

        //adding proposals to according poll, 0 - `no winner`, not use in voting proposals!!!
        for (uint i = 1; i < proposalCount + 1; i++) {
            polls[pollindex].proposals.push(Proposal({
                name: proposalNames[i],
                votedBalance: 0
            }));
        }
        
        polls[pollindex].createdAt = block.timestamp;
        polls[pollindex].finished = false;

        emit StartVoting(recipient, description, proposalCount, polls[pollindex].createdAt);
    }



    /// @dev Give your vote (including votes delegated to you)
    /// @param poll index of the poll,
    /// to @param proposal `proposals[proposal].name`.
    function vote(uint256 poll, uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(hasVotingRights(msg.sender));
        require(!polls[poll].finished || !isFinishedVote(poll), "The poll already finished");
        require(sender.votedProposal[poll] > 0, "Already voted at the Poll.");

        sender.votedProposal[poll] = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        polls[poll].proposals[proposal].votedBalance += sender.balance;

        emit Vote(msg.sender, polls[poll].description, polls[poll].proposals[proposal].name, sender.balance);

        //Save voting for delegated persons
        for (uint i = 0; i < sender.delegators.length; i++) {
            voters[sender.delegators[i]].votedProposal[poll] = proposal;
            polls[poll].proposals[proposal].votedBalance += sender.delegate[sender.delegators[i]];

            emit Vote(sender.delegators[i], polls[poll].description, polls[poll].proposals[proposal].name, sender.delegate[sender.delegators[i]]);
        }
    }



    /// @notice Check the vote is finished or not.
    /// @dev When debating time is over then emit event
    /// @param poll index of the poll.
    function isFinishedVote(uint256 poll) public returns (bool) {
        Poll storage polling = polls[poll];

        if ((polling.createdAt + debatingPeriod < block.timestamp) && !polling.finished) {
            polling.finished = true;
            bytes32 winner = setWinner(poll);

            (bool success, bytes memory returnData) = polling.recipient.call(polling.byteCode);
            require(success, "Call byteCode failed");

            emit FinishVoting(polling.recipient, returnData, winner, block.timestamp);
        }

        return polling.finished;
    }



    /**
     * @dev Computes the winning proposal taking all previous votes into account.
     * @param poll index of the poll.
     */
    function setWinner(uint256 poll) public returns (bytes32) {
        Poll storage polling = polls[poll];
        require(polling.finished, "The poll already open");
        require(polling.winner == "", "The poll already has winner");

        uint256 proposalCount = polling.proposals.length;
        uint256 winBalance = 0;
        bytes32 winner = "no winner";

        //loop proposals in according poll
        for (uint i = 1; i < proposalCount + 1; i++) {
            if ((winBalance < polling.proposals[i].votedBalance) && 
            (minimumQuorum < polling.proposals[i].votedBalance)) {
                winBalance = polling.proposals[i].votedBalance;
                winner = polling.proposals[i].name;
            }
        }

        polling.winner = winner;
        return winner;
    }



    /// @return function that returns entire array of polls
    function getPolls() public view returns (Poll[] memory) {
        return polls;
    }
} 