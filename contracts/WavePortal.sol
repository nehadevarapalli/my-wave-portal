// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
    */
    uint256 private seed;

    /*
     * This is an event in Solidity
    */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * This is a struct named Wave where we store all the information that we want to hold.
    */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    /*
     * Declaring a variable waves which lets us store an array of structs.
     * This is what stores all the waves that are ever sent to the webpage.
    */
    Wave[] waves;

    /*
     * This is an address => unint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
    */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
        */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    /* 
     * The wave function now requires a string called _message which is the message
     * our user sends us from the frontend.
    */
    function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
        */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Must wait 30 seconds before waving again"
        );

        /*
         * Update the current timestamp we have for the user
        */
        lastWavedAt[msg.sender] = block.timestamp;
        
        totalWaves += 1;
        console.log("%s has waved with the message %s", msg.sender, _message);

        /*
         * This is where the wave data is stored in the array.
        */
        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * Generate a new seed for the next user that sends a wave
        */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
        */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The code we had before to send the prize.
            */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        
        //Do not know yet what the following statement does.
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    /*
     * The fucntion getAllWaves returns a struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website.
    */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}