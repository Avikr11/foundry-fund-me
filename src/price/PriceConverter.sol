// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 answer,, uint256 updatedAt,) =
            priceFeed.latestRoundData();

            require(answer > 0, "Invalid price");
            require(updatedAt > 0, "Round not complete");
            require(updatedAt <= block.timestamp, "Future timestamp");
            require(
                block.timestamp - updatedAt <= 3 hours,
                "Stale price"
     );

        uint8 feedDecimals = priceFeed.decimals();

        require(feedDecimals <= 18, "Unsupported feed decimals");

        return uint256(answer) * (uint256(10) ** (18 - feedDecimals));
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);

        return (ethPrice * ethAmount) / 1e18;
    }
}