// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Import Forge standard testing utilities
import {Test, console} from "forge-std/Test.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {ZkSyncChainChecker} from "foundry-devops/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "foundry-devops/FoundryZkSyncChecker.sol";

contract ZkSyncDevOpsTest is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    /// @notice This test checks that the ZkSync chain fails when `skipZkSync` is used.
    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));
        bool success;

        assembly {
            success := call(gas(), ripemd, 0, 0, 0, 0, 0)
        }

        assertTrue(success, "ZkSync check failed unexpectedly");
    }
}
