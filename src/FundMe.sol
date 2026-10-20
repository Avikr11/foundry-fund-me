// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {PriceConverter} from "./price/PriceConverter.sol";
import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    AggregatorV3Interface private s_priceFeed;
    address private immutable i_owner;

    constructor(AggregatorV3Interface priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = priceFeed;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Not owner");
        _;
    }

    function fund() public payable {
        require(msg.value > 0, "Must send ETH");

        uint256 usdAmount = msg.value.getConversionRate(s_priceFeed);
        require(usdAmount >= 5e18, "Minimum $5 required");

        if (addressToAmountFunded[msg.sender] == 0) {
            funders.push(msg.sender);
        }

        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getFunderCount() public view returns (uint256) {
        return funders.length;
    }

    function withdraw() public onlyOwner {
        // 1. Reset every funder's recorded contribution.
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // 2. Clear the funder list.
        funders = new address[](0);

        // 3. Send the contract's entire ETH balance to the owner.
        (bool success,) = payable(i_owner).call{value: address(this).balance}("");

        // 4. Revert if the ETH transfer fails.
        require(success, "Withdraw failed");
    }
}
