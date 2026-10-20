// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

contract MockV3Aggregator {
    uint8 public immutable decimals;
    int256 private price;
    uint256 private s_updatedAt;

    constructor(uint8 _decimals, int256 _initialPrice) {
        decimals = _decimals;
        price = _initialPrice;
        s_updatedAt = block.timestamp;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (1, price, s_updatedAt, s_updatedAt, 1);
    }

    function updateAnswer(int256 newPrice) external {
        price = newPrice;
        s_updatedAt = block.timestamp;
    }

    function setUpdatedAt(uint256 newTimestamp) external {
        s_updatedAt = newTimestamp;
    }
}
