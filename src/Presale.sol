// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BeraBoyzPresale {
    // allowlist with merkle root
    // pay with usdt
    // fixed price
    //
    bytes32 public immutable root;

    constructor(bytes32 _root) {
        root = _root;
    }

    function buy() external {}
}
