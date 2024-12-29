//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    uint8 public  constant DECIMLAS =8;
    int256 public constant STARTING_PRICE = 2000e8;
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaEthConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
         if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;}

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMLAS, STARTING_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory sepoliaEthConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return sepoliaEthConfig;
    }
}
