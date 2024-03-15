// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Shamir} from "../src/Shamir.sol";

contract ShamirDemo {
    using Shamir for *; // Use the library here

    uint256 constant NUM_PLAYERS = 2;
    uint256 public Q;

    // allows handling more than one secret shared number per player
    uint256[][] private sharesA;
    uint256[][] private sharesB;
    uint256[] private resultShares;
    uint256 private playerCount = 0;

    // Event to notify when enough players have submitted their shares
    event SharesReady(uint256 totalPlayers);

    constructor(uint256 fieldSize) {
        Q = fieldSize;
    }
    // Function to submit shares for secret A and B by each player
    function submitShares(uint256[] memory shares, uint playerId) public {
        require(
            playerCount < NUM_PLAYERS,
            "Already reached the required number of players"
        );

        require(
            playerId == 0 || playerId == 1,
            "Invalid player ID, should be 0 or 1"
        );

        if (playerId == 0) {
            sharesA.push(shares);
        } else if (playerId == 1) {
            sharesB.push(shares);
        }

        playerCount++;

        // Check if we have reached the required number of players
        if (playerCount == NUM_PLAYERS) {
            emit SharesReady(playerCount);
        }
    }

    // Function to add shares if the required number of players have submitted their shares
    function addSecretSharedValues() public {
        require(
            playerCount == NUM_PLAYERS,
            "Not enough players have submitted their shares"
        );

        // Initialize arrays to hold the aggregated shares for A and B
        resultShares = new uint256[](sharesA[0].length);

        // Sum shares from players A and B
        for (uint256 i = 0; i < sharesA.length; i++) {
            // FIXME would also need to accumulate result if more than 1 secret shared number
            resultShares = Shamir.add(Q, sharesA[i], sharesB[i]);
        }
    }

    // optional: could also let user reconstruct but could be fun to explore use cases
    function reconstructResult() public view returns (int256) {
        // Reconstruct the secret from the added shares
        int256 resultSecret = Shamir.reconstruct(Q, resultShares);

        return resultSecret;
    }

    // Reset the state to allow for a new round
    function reset() public {
        delete sharesA;
        delete sharesB;
        delete resultShares;
        playerCount = 0;
    }
}
