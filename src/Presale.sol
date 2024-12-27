// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Presale is ReentrancyGuard {
    address public immutable treasury;
    address public immutable usd;
    uint256 public immutable start;
    uint256 public immutable end;
    uint256 public constant TOTAL_LIMIT = 500000e18;
    bytes32 public root;
    uint256 public total;
    mapping(address => uint256) public bought;

    event Buy(address indexed user, uint256 amount);

    error VerifyFailed();
    error TransferFailed();
    error OverLimit();
    error OverTotalLimit();
    error NotStarted();
    error Ended();

    constructor(bytes32 _root, address _usd, address _treasury, uint256 _start, uint256 _end) {
        root = _root;
        usd = _usd;
        treasury = _treasury;
        start = _start;
        end = _end;
    }

    function buy(bytes32[] memory _proof, uint256 _maxAmount, uint256 _amount) external nonReentrant {
        if (block.timestamp < start) revert NotStarted();
        if (block.timestamp > end) revert Ended();
        if (bought[msg.sender] + _amount > _maxAmount) revert OverLimit();
        if (total + _amount > TOTAL_LIMIT) revert OverTotalLimit();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _maxAmount))));
        bool verified = MerkleProof.verify(_proof, root, leaf);
        if (!verified) revert VerifyFailed();
        bool ok = IERC20(usd).transferFrom(msg.sender, treasury, _amount);
        if (!ok) revert TransferFailed();
        bought[msg.sender] += _amount;
        total += _amount;
        emit Buy(msg.sender, _amount);
    }
}
