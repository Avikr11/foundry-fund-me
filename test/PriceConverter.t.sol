
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {PriceConverter} from "../src/price/PriceConverter.sol";
import {AggregatorV3Interface} from "../src/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

// External wrapper so Foundry can test reverts from the internal library.
contract PriceConverterHarness {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) external view returns (uint256) {
        return PriceConverter.getPrice(priceFeed);
    }
}

contract PriceConverterTest is Test {
    MockV3Aggregator priceFeed;
    PriceConverterHarness priceConverterHarness;

    function setUp() public {
        priceFeed = new MockV3Aggregator(8, 2000e8);
        priceConverterHarness = new PriceConverterHarness();
    }

    function testGetPrice() public view {
        uint256 price = PriceConverter.getPrice(
            AggregatorV3Interface(address(priceFeed))
        );

        assertEq(price, 2000e18);
    }

    function testGetConversionRate() public view {
        uint256 ethAmount = 1 ether;

        uint256 conversionRate = PriceConverter.getConversionRate(
            ethAmount,
            AggregatorV3Interface(address(priceFeed))
        );

        assertEq(conversionRate, 2000e18);
    }

    function testGetPriceWith6Decimals() public {
        MockV3Aggregator priceFeed6 = new MockV3Aggregator(6, 2000e6);

        uint256 price = PriceConverter.getPrice(
            AggregatorV3Interface(address(priceFeed6))
        );

        assertEq(price, 2000e18);
    }

    function testGetPriceRevertsWhenStale() public {
        // Set the simulated blockchain timestamp to 10 hours.
        vm.warp(10 hours);

        // Set the feed's last update to four hours ago.
        priceFeed.setUpdatedAt(block.timestamp - 4 hours);

        // Expect the external wrapper call to revert with this reason.
        vm.expectRevert(bytes("Stale price"));

        priceConverterHarness.getPrice(
            AggregatorV3Interface(address(priceFeed))
        );
    }
}
