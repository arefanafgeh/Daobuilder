// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import  "./DaobuilderDataStorage.sol";
contract Daobuilder is DaobuilderDataStorage{



    function getActiveVotings() public view returns (uint[] memory){
        uint[] memory activeVotings = new uint[](lastVotingId);
        uint counter = 0;
        for(uint i = 1; i<=lastVotingId;i++){
            if(votings[i].activated && votings[i].ended!=false && votings[i].start<=block.timestamp && votings[i].end>block.timestamp){
                activeVotings[counter] = i;
                counter+=1;
            }
        }
        return activeVotings;
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
    } 

    function getMyVotings() public view isAdmin(msg.sender) returns (uint[] memory){
        uint[] memory MyVotingList = myVotings[msg.sender];
        return MyVotingList;
    }
    function getVotingOptions(uint _votingId) public view returns (uint[] memory){
        uint[] memory MyVotingList = votingOptions[_votingId];
        return MyVotingList;
    }

    function getVotingResult(uint _votingId) public view{

    }





    /**
    *   بعدش مباحث دايو جداگانه مطالعه میشه
    */


    /**
        Next Challange Voters must own a an specific ERC20 
    */



    /**
    *
    *   آزمون بعدی....MultisSig 
        بعدش مباحث مولتی سیگ جداگانه مطالعه میشه
    *
    */


    /**
    *
    *   آزمون بعدی....ERC20 ,ERC721  , ERC1155
        بعدش مباحث ERC20 و ERC721 و ERC1155
    *   جداگانه مطالعه میشه
    */
}