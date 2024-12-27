//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Presale.sol";

contract Deploy is Script {
    bytes32 public root =
        0x098de4ca8d2d4248c3a5c2c080737a95a6d59fd519cac937d8a70c4edab9bc58;
    address public honey = 0x0E4aaF1351de4c0264C5c7056Ef3777b41BD8e03;
    address public treasury = address(0x43);
    uint256 public start = 1734759820;
    uint256 public end = 1735613020;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new Presale(root, honey, treasury, 1734759820, 1735613020);
        vm.stopBroadcast();
    }
}
