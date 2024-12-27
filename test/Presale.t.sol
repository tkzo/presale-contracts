pragma solidity ^0.8.24;

import {Presale} from "src/Presale.sol";
import {Test} from "forge-std/Test.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MockERC20} from "src/MockERC20.sol";

contract PresaleTest is Test {
    Presale public presale;
    address public usd;
    uint256 public amount = 5000e18;
    address public claimer = 0x45953D7FB14419FedF06A32deFC5C2B45f1F5a1F;
    bytes32 public immutable root = 0xce8e184cf3ed01b7f16b08d4ba454fdbd37be45ea22d885692ef8ff0e383a8e8;
    bytes32 public immutable correct_proof = 0xb92c48e9d7abe27fd8dfd6b5dfdbfb1c9a463f80c712b66f3a5180a090cccafc;
    bytes32 public immutable wrong_proof = 0xb92c48e9d7abe27fd8dfd6b5dfdbfb1c9a463f80c712b66f3a5180a090cccaff;

    error VerifyFailed();
    error OverLimit();
    error OverTotalLimit();
    error NotStarted();
    error Ended();

    event Buy(address indexed user, uint256 amount);

    receive() external payable {}

    function setUp() public {
        usd = address(new MockERC20("USD", "USD"));
        IERC20(usd).transfer(claimer, amount);
        presale = new Presale(root, address(usd), address(0x42), block.timestamp + 1, block.timestamp + 1 days);
    }

    function test_Buy() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = correct_proof;
        vm.startPrank(claimer);
        IERC20(usd).approve(address(presale), amount);
        vm.warp(block.timestamp + 1);
        vm.expectEmit();
        emit Buy(claimer, amount);
        presale.buy(proof, amount, amount);
        assertEq(presale.bought(claimer), amount);
        assertEq(presale.total(), amount);
        assertEq(IERC20(usd).balanceOf(presale.treasury()), amount);
        vm.stopPrank();
    }

    function test_BuyNotStarted() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = correct_proof;
        vm.startPrank(claimer);
        IERC20(usd).approve(address(presale), amount);
        vm.expectRevert(NotStarted.selector);
        presale.buy(proof, amount, amount);
        vm.stopPrank();
    }

    function test_BuyEnded() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = correct_proof;
        vm.startPrank(claimer);
        IERC20(usd).approve(address(presale), amount);
        vm.warp(block.timestamp + 1 days + 1);
        vm.expectRevert(Ended.selector);
        presale.buy(proof, amount, amount);
        vm.stopPrank();
    }

    function test_BuyOverLimit() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = correct_proof;
        vm.startPrank(claimer);
        IERC20(usd).approve(address(presale), amount + 1);
        vm.warp(block.timestamp + 1);
        vm.expectRevert(OverLimit.selector);
        presale.buy(proof, amount, amount + 1);
        vm.stopPrank();
    }

    function test_BuyOverTotalLimit() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = correct_proof;
        vm.startPrank(claimer);
        IERC20(usd).approve(address(presale), 1);
        vm.store(address(presale), bytes32(uint256(2)), bytes32(uint256(presale.TOTAL_LIMIT())));
        vm.warp(block.timestamp + 1);
        vm.expectRevert(OverTotalLimit.selector);
        presale.buy(proof, amount, 1);
        vm.stopPrank();
    }

    function test_BuyVerifyFailed() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = wrong_proof;
        vm.startPrank(claimer);
        IERC20(usd).approve(address(presale), amount);
        vm.warp(block.timestamp + 1);
        vm.expectRevert(VerifyFailed.selector);
        presale.buy(proof, amount, amount);
        vm.stopPrank();
    }
}
