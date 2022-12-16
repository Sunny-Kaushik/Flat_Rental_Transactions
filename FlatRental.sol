// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract FlatRental 
{
    address owner;
    constructor() public{
        owner = msg.sender;
    }
    // Add yourself as a Renter
    struct Renter {
        address payable transactionAddress;
        string _firstname;string _lastName;
        bool active;
        uint balance;uint due;
        uint start;uint end; 
    }
    mapping (address => Renter) public renters;
    function addRenter(address payable transactionAddress, string memory _firstname, string memory _lastName, bool active, uint balance, uint due, uint start, uint end) public {
        renters[transactionAddress] = Renter(transactionAddress, _firstname, _lastName, active, balance, due, start, end);
    }

    // Check out the flat and set that your flat is currently vacated
    function checkOut(address transactionAddress) public {
        //if it has a pending balance then it will display the message "You have a pending balance"
        require(renters[transactionAddress].due == 0, "Pay to renew your account.");
        //check whether the flat is available for renting or not
        renters[transactionAddress].active = true;
        renters[transactionAddress].start = block.timestamp;
    }

    // Check in a the flat and set that the flat currently not vacant
    function checkIn(address transactionAddress) public {
        require(renters[transactionAddress].active == true, "Flat has an active user.");
        renters[transactionAddress].active = false;
          //setting the duration of the stay
        renters[transactionAddress].end = block.timestamp;
        setDue(transactionAddress);
    }

    // Get total duration of flat used
    function renterTimespan(uint start, uint end) internal pure returns(uint) {
        return end - start;
    }

    function getTotalDuration(address transactionAddress) public view returns(uint) {
        require(renters[transactionAddress].active == false, "Flat is currently vacant.");
        //gives the total timespan to stay in flat
        uint timespan = renterTimespan(renters[transactionAddress].start, renters[transactionAddress].end);
        //divide by 60 to convert to minutes as in solidity time is recorded in seconds
        uint timespanInMinutes = timespan / 60;
        return timespanInMinutes;
    }

    // setting the time to check in and check out, if not done within time, user will be notified
    function setDue(address transactionAddress) internal {
        //gives the total timespan to stay in flat
        uint timespanMinutes = getTotalDuration(transactionAddress);
        //User will be notified before his acc. exceeds the payment he had done for the stay
        //if he doesn't vacate then for every five finutes extra stay 
        //I am charging 5000000000000000 wei
        uint fiveMinuteIncrements = timespanMinutes / 5;
        renters[transactionAddress].due = fiveMinuteIncrements * 5000000000000000;
    }

    //This code is to accept the payment for the flat usage

    // function makePayment(address transactionAddress) payable public 
    // {
    //     require(renters[transactionAddress].due > 0, "You do not have anything due at this time.");
    //     require(renters[transactionAddress].balance > msg.value, "You do not have enough funds to cover payment. Please make a deposit.");
    //     renters[transactionAddress].balance -= msg.value;
    //     renters[transactionAddress].due = 0;
    //     renters[transactionAddress].start = 0;
    //     renters[transactionAddress].end = 0;
    // }

    uint _start;
    uint _end;
    //This modifier will notify the user if the timestamp passes the time for which he has paid
    modifier timerOver
    {
        require(now <= _end, "Your contract to rent this flat has expired, kindly update the balance to continue using it.");
        _;
    }
    //setting the initial start time as now 
    function start() public
    {
        _start=now;
    }
    //passing total time to this function and then setting the end variable to the value after which it should end
    function end(uint totalTime) public
    {
        _end = totalTime + _start;
    }
    //this function will return the amount of time left whenever accessed
    function getTimeLeft() public timerOver view returns (uint)
    {
        return _end-now;
    }
}