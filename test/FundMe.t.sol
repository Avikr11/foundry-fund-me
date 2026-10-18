
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "../src/interfaces/AggregatorV3Interface.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    MockV3Aggregator priceFeed;
    receive() external payable {}

    function setUp() public {
        priceFeed = new MockV3Aggregator(8, 2000e8);
        fundMe = new FundMe(
            AggregatorV3Interface(address(priceFeed))
        );
    }

    function test_FundWithZeroETHReverts() public {
        vm.expectRevert("Must send ETH");
        fundMe.fund();
    }

    function test_FundwithETH() public {
        vm.deal(address(this), 1 ether);

        fundMe.fund{value: 1 ether}();

        assertEq(address(fundMe).balance, 1 ether);
    }

    function test_FundFromUser() public {
        address user = makeAddr("user");

        vm.deal(user, 2 ether);

        vm.prank(user);
        fundMe.fund{value: 1 ether}();

        assertEq(address(fundMe).balance, 1 ether);
        assertEq(user.balance, 1 ether);
    }

    function test_FunderContributionRecorded() public {
        address user = makeAddr("user");

        vm.deal(user, 2 ether);
        vm.prank(user);
        fundMe.fund{value: 1 ether}();

        assertEq(fundMe.addressToAmountFunded(user), 1 ether);
    }

    function test_FunderRecordedInArray() public {
        address user = makeAddr("user");

        vm.deal(user, 2 ether);
        vm.prank(user);
        fundMe.fund{value: 1 ether}();

        assertEq(fundMe.funders(0), user);
    }

    function test_RepeatedFunderIsRecordedOnlyOnce() public {
        address alice = makeAddr("alice");

        vm.deal(alice, 5 ether);

        vm.startPrank(alice);
        fundMe.fund{value: 1 ether}();
        fundMe.fund{value: 2 ether}();
        vm.stopPrank();

        assertEq(fundMe.addressToAmountFunded(alice), 3 ether);
        assertEq(fundMe.funders(0), alice);
        assertEq(fundMe.getFunderCount(), 1);
    }

    function test_FundBeBelowMinimumReverts() public {
        vm.deal(address(this), 0.001 ether);

        vm.expectRevert("Minimum $5 required");
        fundMe.fund{value: 0.001 ether}();
   }

   function test_FundExactlyMinimumSucceeds() public {
        vm.deal(address(this), 0.0025 ether);

        fundMe.fund{value: 0.0025 ether}();

        assertEq(address(fundMe).balance, 0.0025 ether);
    }

    function test_FundAboveMinimumSucceeds() public {
        vm.deal(address(this), 0.01 ether);

        fundMe.fund{value: 0.01 ether}();

        assertEq(
          fundMe.addressToAmountFunded(address(this)),
          0.01 ether
       );

    }

    function testOwnerCanWithdrawAndResetFunders() public {
        vm.deal(address(this), 1 ether);

        fundMe.fund{value: 1 ether}();

        assertEq(fundMe.getFunderCount(), 1);
        assertEq(fundMe.addressToAmountFunded(address(this)), 1 ether);

        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.addressToAmountFunded(address(this)), 0);
        assertEq(fundMe.getFunderCount(), 0);
    }

    function testNonOwnerCannotWithdraw() public {
        address nonOwner = makeAddr("nonOwner");

        vm.prank(nonOwner);
        vm.expectRevert(bytes("Not owner"));

        fundMe.withdraw();
    }


    function testWithdrawResetsMultipleFunders() public {
        address funder1 = makeAddr("funder1");
        address funder2 = makeAddr("funder2");

        vm.deal(funder1, 1 ether);
        vm.deal(funder2, 1 ether);

        vm.prank(funder1);
        fundMe.fund{value: 1 ether}();

        vm.prank(funder2);
        fundMe.fund{value: 1 ether}();

        assertEq(fundMe.getFunderCount(), 2);
        assertEq(fundMe.addressToAmountFunded(funder1), 1 ether);
        assertEq(fundMe.addressToAmountFunded(funder2), 1 ether);

        uint256 ownerBalanceBefore = address(this).balance;

        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getFunderCount(), 0);
        assertEq(fundMe.addressToAmountFunded(funder1), 0);
        assertEq(fundMe.addressToAmountFunded(funder2), 0);
        assertEq(address(this).balance, ownerBalanceBefore + 2 ether);
    }


    function testWithdrawRevertsIfOwnerRejectsETH() public {
        // Create a contract that rejects incoming ETH.
        RejectingReceiver receiver = new RejectingReceiver();

        // The receiver deploys FundMe, so it becomes the owner.
        FundMe rejectingFundMe = receiver.deployFundMe(
           AggregatorV3Interface(address(priceFeed))
        );

        // Give this test contract ETH and fund the contract.
        vm.deal(address(this), 1 ether);
        rejectingFundMe.fund{value: 1 ether}();

        // Verify the contribution was recorded.
        assertEq(rejectingFundMe.addressToAmountFunded(address(this)), 1 ether);
        assertEq(rejectingFundMe.getFunderCount(), 1);

        // The owner tries to withdraw, but the receiver rejects ETH.
        vm.expectRevert(bytes("Withdraw failed"));
        receiver.withdraw(rejectingFundMe);

        // The failed transaction must leave the state unchanged.
        assertEq(address(rejectingFundMe).balance, 1 ether);
        assertEq(rejectingFundMe.addressToAmountFunded(address(this)), 1 ether);
        assertEq(rejectingFundMe.getFunderCount(), 1);
    }


}


contract RejectingReceiver {
    function deployFundMe(
        AggregatorV3Interface priceFeed
    ) external returns (FundMe) {
        return new FundMe(priceFeed);
    }

    function withdraw(FundMe fundMe) external {
        fundMe.withdraw();
    }

    receive() external payable {
        revert("ETH rejected");
    }
}
