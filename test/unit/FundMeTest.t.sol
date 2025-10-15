// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract FundMeTest is Test {  // ✅ renamed from FundMe -> FundMeTest
    FundMe fundMe;
    MockV3Aggregator mockPriceFeed;

    function setUp() public {
        mockPriceFeed = new MockV3Aggregator(8, 2000 * 1e8); // example constructor args
        fundMe = new FundMe(address(mockPriceFeed));
    }

    function testFund() public {
        // your test logic
    }

    function testWithdraw() public {
        // your test logic
    }
}
