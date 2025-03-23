// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import  "./Ownable.sol";
contract DaobuilderDataStorage is Ownable{

    /**
    *
    *   Data Storage
    *
    * */
    struct VotingAdmin{
        address admin;
        bool enabled ;
        bool added;
    }
    mapping(uint16=>VotingAdmin) public votingAdmins;
    mapping(address=>uint16) public votingAdminsShort;
    uint16 public lastVotingAdminId = 1;
 

    struct Voter{
        bool enabled;
        uint8 votingPower;
        bool added;
    }
    uint16 public lastVoterId = 1;
    mapping(address=>Voter) public voters;
    mapping(uint16=>address) public votersAddresses;

    struct Voting{
        address creator;
        uint32 start;
        uint32 end;
        bool ended;
        bool activated;
        string title;
        string descriptions;
        uint32 createdAt;
    }
    mapping(uint16=>Voting) public votings;
    uint16 public lastVotingId = 1;
    mapping(address=>uint16[]) public myVotings;

    struct Option{
        string option;
        bool enabled;
        uint16 votingId;
    }
    mapping(uint64=>Option) public options;
    uint64 public lastOptionId=1;
    mapping(uint16=>uint64[]) public votingOptions;

    struct Vote{
        uint16 votingId;
        address voter;
        address voingInsteadOf;
        string option;
        uint32 timeofVote;
        uint8 power;
    }
    mapping(uint64=>Vote) public votes;
    uint64  public lastVoteId = 1;
    mapping(address=>uint64[]) public votersVotes;
    mapping(uint16=>uint64[]) public votingsVotes;
    struct Delegations{
        mapping(address=>address) delegaterToDelegatee;
    }
    mapping(uint16=>Delegations)  votingsDelegations;



    /**
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    From Now on , fix every singe funciton , modifier and event data based on the correct data structure
    */

    /**
    *
    *   Data Storage
    *
    * */

    /**
    *   Events section
    * */
    event NewAdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event VoterAdded(address indexed voter);
    event VoterRemoved(address indexed voter);
    event VoterEnabled(address indexed voter);
    event VoterDisabled(address indexed voter);
    event VoterPowerDecreased(address indexed voter);
    event VoterPowerIncreased(address indexed voter);
    event VotingDataChanged(uint indexed votingIndex , string  msg);
    event VotingOptionChanged(uint indexed votingIndex , string  option, string  msg);
    event VotingRightDelegated(uint indexed votingIndex  , address indexed delegater , address indexed delegatee);
    event VotingRightUnDelegated(uint indexed votingIndex  , address indexed delegater , address indexed delegatee);
    event VoteRegistered(uint indexed votingIndex , uint indexed option , address indexed voter);

    /**
    *   Events section
    * */


    /**
    *   modifiers section
    * */
    modifier VoterExists(address _voter){
        require(voters[_voter].added ,"Voter does not exists" );
        _;
    }
    modifier VoterDoesNotExists(address _voter){
        require(!voters[_voter].added ,"Voter Already exists" );
        _;
    }
    modifier VoterCanVote(address _voter){
        require(voters[_voter].added ,"Voter does not exists" );
        require(voters[_voter].enabled ,"Voter does not exists" );
        _;
    }
    modifier VoterMinVotingPowerCheck(address _voter){
        require(voters[_voter].votingPower>1 ,"Voter does not exists" );
        _;
    }
    modifier isAdmin(address _admin){
        require(votingAdmins[votingAdminsShort[_admin]].enabled , "Address is not and Admin");
        _;
    }
    modifier isAdminOf(address _admin , uint _votingId){
        if(!isOwner()){
            require(votings[uint16(_votingId)].creator == _admin ,"You have no access to manage this voting");
        }
        _;
    }
    modifier isVotingActive(uint _votingId){
        Voting memory voting = votings[_votingId];
         require(voting.activated ,"Voting is Not Active");
         require(!voting.ended ,"Voting is Ended");
         require(voting.end >voting.start ,"Voting is Ended");
         require(voting.end/1000 > uint32(block.timestamp) ,"Voting is Ended");
         require(uint32(block.timestamp) > voting.start/1000  ,"Wierdly voting start is NOT less than now");
         _;
    }
    modifier VotingNotPublishedYet(uint _votingId){
         require(!votings[uint16(_votingId)].activated ,"Voting is Not Active");
         _;
    }
    modifier NoVoteRegesteredYet(uint _votingId , address _voteraddress){
        //No vote registered for me
        uint[] memory Myvotes = votersVotes[_voteraddress];
        uint[] storage _votes = votes;
        for(uint i=0;i<Myvotes.length;i++){
            if(_votes[Myvotes[i]].votingId==_votingId){
                require(_votes[Myvotes[i]].voingInsteadOf!=_voteraddress , "You have already a registered vote for this voting");
                // require(votes[Myvotes[i]].votingId!=_votingId , "You have already a registered vote for this voting");
            }
        }
        _;
    }

    modifier CanVoteBehalfOf(uint _votingId ,address _voter , address _onbehalfOf){
        if(_voter!=_onbehalfOf){
            require(votingsDelegations[_votingId].delegaterToDelegatee[_onbehalfOf]==_voter,"You have no right to vote for someone's else");
        }
        _;
    }


    modifier IsOptionValid(uint _votingId ,uint _votingOptionId){
        Option memory opt =options[uint64(_votingOptionId)]; 
        require(opt.enabled ,"Selected Option is not in valid defined options ");
        require(opt.votingId==uint16(_votingId) ,"Selected Option is not in valid defined options ");
        _;
    }
    /**
    *   modifiers section
    * */




    /**
    Manage Voting Admins
     */
    function addVotingAdmin(address _newadmin) external OnlyOwner {
        uint _locallastVotingAdminId = lastVotingAdminId;
        VotingAdmin storage votingAdmin = votingAdmins[votingAdminsShort[_newadmin]];

        if(!votingAdmin.added ){
            votingAdminsShort[_newadmin] = _locallastVotingAdminId;
            votingAdmins[_locallastVotingAdminId] = VotingAdmin(_newadmin , true,true);
            _locallastVotingAdminId+=1;
        }else{
            votingAdmin.enabled = true;
        }
        lastVotingAdminId = _locallastVotingAdminId;
        emit NewAdminAdded(_newadmin);
    }
    
  
    function removeVotingAdmin(address _address) external OnlyOwner isAdmin(_address) {
        votingAdmins[votingAdminsShort[_address]].enabled = false;
        emit AdminRemoved(_address);
    }
    function isUserAdmin(address _address) public view returns (bool){
        return votingAdmins[votingAdminsShort[_address]].enabled;
    }

    /**
    Manage Voters
     */
    function addVoter(address _voter) external OnlyOwner VoterDoesNotExists(_voter){
        Voter storage _voterinfo = voters[_voter];
        _voterinfo.votingPower=1;
        _voterinfo.added=true;
        votersAddresses[lastVoterId] = _voter;
        lastVoterId+=1;
        emit VoterAdded(_voter);
    }

    function enableVoter(address _voter) external OnlyOwner VoterExists(_voter){
        voters[_voter].enabled=true;
        emit VoterEnabled(_voter);
    }
    function disableVoter(address _voter) external OnlyOwner VoterExists(_voter){
        voters[_voter].enabled=false;
        emit VoterDisabled(_voter);
    }
    function increaseVoterPower(address _voter) external OnlyOwner VoterExists(_voter){
        voters[_voter].votingPower+=1;
        emit VoterPowerIncreased(_voter);
    }
    function decreaseVoterPower(address _voter) external OnlyOwner VoterExists(_voter) VoterMinVotingPowerCheck(_voter){
        voters[_voter].votingPower-=1;
        emit VoterPowerDecreased(_voter);
    }
    function isVoter(address _address) public view returns (bool){
        return voters[_address].votingPower>=1;
    }

    

    /**
    Manage Votings
     */
    function addVoting(uint _start , uint _end , string memory _title , string memory _description) external isAdmin(msg.sender) returns (uint) {
        uint16 _lastVotingId = lastVotingId;
        Voting storage newvoting =votings[_lastVotingId];
        newvoting.creator = msg.sender;
        newvoting.start=uint32(_start);
        newvoting.end=uint32(_end);
        // newvoting.ended;
        // newvoting.activated;
        newvoting.title=_title;
        newvoting.descriptions=_description;
        newvoting.createdAt=uint32(block.timestamp);
        // votings[lastVotingId] = Voting(msg.sender, _start, _end, false , false,_title , _description , block.timestamp) ;
        uint16[] storage myvotings =myVotings[msg.sender];
        _lastVotingId+=1;
        lastVotingId = _lastVotingId;
        myvotings.push(_lastVotingId);
        emit VotingDataChanged(_lastVotingId , "Voting Added");
        return _lastVotingId;

    }
    function changeVotingStartDate(uint _votingId , uint _startdate) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) VotingNotPublishedYet(_votingId) {
        votings[uint16(_votingId)].start = uint32(_startdate);
        emit VotingDataChanged(_votingId , "Voting start date changed");
    }
    function changeVotingEndDate(uint _votingId , uint _enddate) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) VotingNotPublishedYet(_votingId) {
        votings[uint16(_votingId)].end = uint32(_enddate);
        emit VotingDataChanged(_votingId , "Voting end date changed");
    }
    function changeVotingTitle(uint _votingId , string memory _title) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) VotingNotPublishedYet(_votingId) {
        votings[uint16(_votingId)].title = _title;
        emit VotingDataChanged(_votingId , "Voting title changed");
    }    
    function changeVotingDescription(uint _votingId , string memory _description) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) VotingNotPublishedYet(_votingId) {
        votings[uint16(_votingId)].descriptions = _description;
        emit VotingDataChanged(_votingId , "Voting description changed");
    }
    function setVotingEnded(uint _votingId) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) isVotingActive(_votingId) {
        votings[uint16(_votingId)].ended = true;
        emit VotingDataChanged(uint16(_votingId) , "Voting is set ended now");
    }

    function setVotingActive(uint _votingId) external OnlyOwner() {
        votings[uint16(_votingId)].activated = true;
        emit VotingDataChanged(uint16(_votingId) , "Voting is set Active now");
    }

    /**
    Manage Voting Options
     */
    function addVotingOption(uint _votingId , string memory option) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) VotingNotPublishedYet(_votingId){
        uint64 _lastOptionId = uint64(lastOptionId);
        uint64[] storage _votingOptions = votingOptions[uint16(_votingId)];
        options[_lastOptionId] = Option(option,true , uint16(_votingId));
        _votingOptions.push(_lastOptionId);
        lastOptionId+=1;
        emit VotingOptionChanged(uint16(_votingId) , option , "Voting Option Added");
    }
    function removeVotingOption(uint _votingId , uint option) external isAdmin(msg.sender) isAdminOf(msg.sender , _votingId) VotingNotPublishedYet(_votingId){
        options[uint64(option)].enabled = false;
        emit VotingOptionChanged(uint16(_votingId) , options[uint64(option)].option , "Voting option removed");
    }

}