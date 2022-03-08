pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Counter {
    //If the number is to large for javascript to handle we can just make it so its
    uint32 counter;

    event CounterInc(uint256 counter);

    function count() public {
        counter++;
        console.log("Counter is now", counter);
        emit CounterInc(counter);
    }

    function getCounter() public view returns (uint32) {
        return counter;
    }
}
