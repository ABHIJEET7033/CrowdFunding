// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding
{
    mapping(address=>uint) public contributors;
    address manager;
    uint minimumcontribution;
    uint deadline;
    uint target;
    uint raisedamount;
    uint noofcontributors;
 
     struct Request
     {
         string reason;
         address payable participent;
         uint value;
         bool completed;
         uint noofvoters;
         mapping(address=>bool) voters; 
     }

     mapping(uint=>Request) public requests;
     uint public numrequest;

    constructor(uint _target,uint _deadline)
    {
        target=_target;
        deadline= block.timestamp + _deadline;
        minimumcontribution = 100 wei;
        manager = msg.sender;
    }
    
   
    function sendether() payable public
    {
        require(deadline > block.timestamp,"Deadline has passed");
        require(msg.value >= minimumcontribution,"Amount less than minimum amount to send");

        if(contributors[msg.sender]==0)
        noofcontributors++;

        raisedamount = raisedamount + msg.value;
        contributors[msg.sender] = contributors[msg.sender] + msg.value;
         

    }

    function getcontractbalance() public view returns(uint)
    {
       return address(this).balance;
    }

    function refund() public payable
    {
        require(deadline > block.timestamp && target > raisedamount,"Not eligible for refund process");
        require(contributors[msg.sender]!=0,"Nothing contributed so go and sleep");

        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
  
    modifier onlyManager
    {
        require(msg.sender == manager,"Not eligible fort modifying this function");
        _;
    }

    function createrequest(string memory _reason,address  payable _participent,uint _value) public onlyManager
    {
        Request storage newrequest = requests[numrequest];
        numrequest++;

        newrequest.reason=_reason;
        newrequest.participent=_participent;
        newrequest.value=_value;
        newrequest.completed=false;
        newrequest.noofvoters=0;

    }

    function voterequest(uint requestNo) public
    {
        require(contributors[msg.sender]!=0,"Nothing contributed");
        require(requests[requestNo].voters[msg.sender]==false,"You already voted");
        requests[requestNo].voters[msg.sender]=true;
        requests[requestNo].noofvoters++;

    }

    function makepayments(uint requestNo) payable public
    {
         require(requests[requestNo].completed==false,"Request has been already been resolved");
         require(requests[requestNo].value > raisedamount,"Amount not raise fuuly for payment");
         require(requests[requestNo].noofvoters > noofcontributors/2);

         address payable user = requests[requestNo].participent;
         user.transfer(requests[requestNo].value);
         raisedamount = raisedamount - requests[requestNo].value;
         requests[requestNo].completed =true;

    }

}