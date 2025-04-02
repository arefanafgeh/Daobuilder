// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() payable{
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier OnlyOwner(){
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool){
        return msg.sender==_owner;
    }

    function transferOwnership(address to) public payable OnlyOwner {
        _transferOwnership(to);
    } 
    function _transferOwnership(address to) internal {
        require(to!=address(0));
        emit OwnershipTransferred(_owner, to);
        _owner = to;
    }
}