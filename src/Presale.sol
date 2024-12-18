// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/utils/Pausable.sol";

contract BeraBoyzPresale is ReentrancyGuard, Pausable {
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant MAXLONG =
        0x55d398326f99059fF775485246999027B3197955;
    bytes32 public immutable root;
    uint256 public constant LIMIT = 5000 * 1e18;
    uint256 public constant START = 1630454400;
    uint256 public constant END = 1630458000;
    mapping(address => uint256) public bought;

    event Buy(address indexed user, uint256 amount);

    error VerifyFailed();
    error TransferFailed();
    error OnlyMaxLong();
    error OverLimit();

    constructor(bytes32 _root) {
        root = _root;
    }

    function buy(
        bytes32[] memory _proof,
        uint256 _amount
    ) external nonReentrant {
        bool verified = MerkleProof.verify(
            _proof,
            root,
            keccak256(abi.encodePacked(msg.sender))
        );
        if (!verified) revert VerifyFailed();
        if (bought[msg.sender] + _amount > LIMIT) revert OverLimit();
        bool ok = IERC20(USDT).transferFrom(msg.sender, address(this), _amount);
        if (!ok) revert TransferFailed();
        bought[msg.sender] += _amount;
    }

    function withdraw() external {
        if (msg.sender != MAXLONG) revert OnlyMaxLong();
        uint256 balance = IERC20(USDT).balanceOf(address(this));
        bool ok = IERC20(USDT).transfer(MAXLONG, balance);
        if (!ok) revert TransferFailed();
    }
}
