// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Presale is ReentrancyGuard, Ownable {
    address public constant ADMIN = 0xC370b50eC6101781ed1f1690A00BF91cd27D77c4;
    address public constant SECOND_ADMIN =
        0xC370b50eC6101781ed1f1690A00BF91cd27D77c4;
    uint256 public constant LIMIT = 5000e18;
    uint256 public constant TOTAL_LIMIT = 500000e18;
    address public immutable usd;
    uint256 public immutable start;
    uint256 public immutable end;

    mapping(address => bool) public collections;
    mapping(address => uint256) public bought;
    uint256 public total;

    event Buy(address indexed user, uint256 amount);

    error TransferFailed();
    error OnlyAdmin();
    error OverLimit();
    error OverTotalLimit();
    error NotStarted();
    error Ended();
    error NotAllowed();
    error NotEligible();

    constructor(
        address _usd,
        uint256 _start,
        uint256 _end
    ) Ownable(msg.sender) {
        usd = _usd;
        start = _start;
        end = _end;
    }

    function buy(address _collection, uint256 _amount) external nonReentrant {
        if (block.timestamp < start) revert NotStarted();
        if (block.timestamp > end) revert Ended();
        if (bought[msg.sender] + _amount > LIMIT) revert OverLimit();
        if (total + _amount > TOTAL_LIMIT) revert OverTotalLimit();
        if (!collections[_collection]) revert NotAllowed();
        if (IERC721(_collection).balanceOf(msg.sender) == 0)
            revert NotEligible();
        bool ok = IERC20(usd).transferFrom(msg.sender, address(this), _amount);
        if (!ok) revert TransferFailed();
        bought[msg.sender] += _amount;
        total += _amount;
        emit Buy(msg.sender, _amount);
    }

    function withdraw() external {
        if (msg.sender != ADMIN && msg.sender != SECOND_ADMIN)
            revert OnlyAdmin();
        uint256 balance = IERC20(usd).balanceOf(address(this));
        bool ok = IERC20(usd).transfer(ADMIN, balance);
        if (!ok) revert TransferFailed();
    }

    function addCollection(address _collection) external onlyOwner {
        collections[_collection] = true;
    }
}
