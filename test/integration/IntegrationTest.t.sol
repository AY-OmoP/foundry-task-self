// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract IntegrationTest is Test {
    FundMe fundMe;
    MockV3Aggregator mockAggregator;
    address user;

    function setUp() public {
        user = address(1);
        mockAggregator = new MockV3Aggregator(8, 2000 * 1e8); // 8 decimals
        fundMe = new FundMe(address(mockAggregator));
    }

    function testUserCanFundInteraction() public {
    address USER = makeAddr("user");
    vm.deal(USER, 1 ether); // 👈 Give the user ETH

    vm.prank(USER);
    fundMe.fund{value: 0.1 ether}();

    uint256 fundedAmount = fundMe.addressToAmountFunded(USER);
    assertEq(fundedAmount, 0.1 ether);
}
}
