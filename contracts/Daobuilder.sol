// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import  "./DaobuilderDataStorage.sol";
contract Daobuilder is DaobuilderDataStorage{



    function getActiveVotings() public view returns (uint[] memory){
        uint[] memory activeVotings = new uint[](lastVotingId);
        uint counter = 0;
        for(uint i = 1; i<=lastVotingId;i++){
            if(votings[i].activated && votings[i].ended==false && votings[i].start/1000 <= block.timestamp && votings[i].end/1000 > block.timestamp){
                activeVotings[counter] = i;
                counter+=1;
            }
        }
        return activeVotings;
    }

    function getMyVotings() public view isAdmin(msg.sender) returns (uint[] memory){
        uint[] memory MyVotingList = myVotings[msg.sender];
        return MyVotingList;
    }
    
    function getVotingOptions(uint _votingId) public view returns (uint[] memory){
        uint[] memory MyVotingList = votingOptions[_votingId];
        return MyVotingList;
    }
    
    function delegateMyVote(uint _votingId ,address _to) 
        external  isVotingActive(_votingId) 
                  VoterCanVote(msg.sender) 
                  NoVoteRegesteredYet(_votingId , msg.sender){

        Delegations storage delegationsOnthisVoting = votingsDelegations[_votingId];
        delegationsOnthisVoting.delegaterToDelegatee[msg.sender] = _to;
        emit VotingRightDelegated(_votingId , msg.sender , _to);
    }

    function revokeDelegation(uint _votingId ,address _to)
        external  isVotingActive(_votingId) 
                  VoterCanVote(msg.sender)
                  NoVoteRegesteredYet(_votingId , msg.sender){
        Delegations storage delegationsOnthisVoting = votingsDelegations[_votingId];
        delete delegationsOnthisVoting.delegaterToDelegatee[msg.sender];
        emit VotingRightUnDelegated(_votingId , msg.sender , _to);
    }

    function getMyDelegationOnVoting(uint _votingId) public view
                    isVotingActive(_votingId) returns (address addrss){
            Delegations storage thisVotingDelegations = votingsDelegations[_votingId];
            return thisVotingDelegations.delegaterToDelegatee[msg.sender];
    }

    function vote(uint _votingId , uint _selectedOption , address _onbehalfOf) 
        external isVotingActive(_votingId)
                 NoVoteRegesteredYet(_votingId,_onbehalfOf)
                 VoterCanVote(msg.sender)
                 CanVoteBehalfOf(_votingId ,msg.sender , _onbehalfOf)
                 IsOptionValid(_votingId , _selectedOption){
        lastVoteId+=1;
        votes[lastVoteId] = Vote(_votingId,msg.sender,_onbehalfOf,options[_selectedOption].option,block. timestamp,voters[_onbehalfOf].votingPower);
        uint[] storage userVotes = votersVotes[_onbehalfOf];
        userVotes.push(lastVoteId);
        uint[] storage votingVotes = votingsVotes[_votingId];
        votingVotes.push(lastVoteId);
        emit VoteRegistered(_votingId , _selectedOption , _onbehalfOf);
    } 


    function getVotingsVotes(uint _votingId) public view returns (uint[] memory){
        uint[] memory Votingvotes = votingsVotes[_votingId];
        return Votingvotes;
    }
    function getVotersVotes() public view returns (uint[] memory){
        uint[] memory MyVotes = votersVotes[msg.sender];
        return MyVotes;
    }

}