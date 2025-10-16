// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 🧰 Imports
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

/// @notice Example interaction script for your FundMe contract
contract Interactions is Script {
    /// @notice Adds funds to the latest deployed FundMe contract
    function fundFundMe() public {
        // Get the most recent FundMe deployment for the current chain
        address mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        FundMe(payable(mostRecentFundMe)).fund{value: 0.1 ether}();
    }

    /// @notice Withdraws funds from the latest deployed FundMe contract
    function withdrawFundMe() public {
        address mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        FundMe(payable(mostRecentFundMe)).withdraw();
        vm.stopBroadcast();
    }

    /// @notice Entry point for Foundry script execution
    function run() external {
        // Start broadcast (sends actual tx if private key set)
        vm.startBroadcast();

        // Example: call fund function
        fundFundMe();

        // You can also call withdrawFundMe() if needed
        // withdrawFundMe();

        vm.stopBroadcast();
    }
}
