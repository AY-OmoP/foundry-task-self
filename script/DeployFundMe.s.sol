// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract DeployFundMe is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    function run() public returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(address(new MockV3Aggregator(DECIMALS, INITIAL_PRICE)));
        vm.stopBroadcast();
        return fundMe;
    }

    // For testing only, no broadcast needed
    function deployForTest() public returns (FundMe) {
        FundMe fundMe = new FundMe(address(new MockV3Aggregator(DECIMALS, INITIAL_PRICE)));
        return fundMe;
    }
}
