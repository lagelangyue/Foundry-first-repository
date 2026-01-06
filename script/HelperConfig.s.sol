// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public currentActiveNetworkConfig; // 正确缩进

    struct NetworkConfig { // 和变量同级缩进
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            currentActiveNetworkConfig = getSepoliaEthConfig();
        } else {
            currentActiveNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (currentActiveNetworkConfig.priceFeed != address(0)) {
            return currentActiveNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
