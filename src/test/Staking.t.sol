// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "../Staking.sol";
import "../Token.sol";

contract StakingTest is DSTest, Test {
    Staking private staking;
    Token private wag;

    address gov = address(0xabcd);
    address alice = address(0x12341234);
    address bob = address(0x67896789);
    address cletus = address(0x12345678);

    uint256 public REWARD_RATE = 100;

    function setUp() public {
        wag = new Token(gov);
        staking = new Staking(address(wag), REWARD_RATE, gov);
        vm.deal(gov, 1 ether);
        vm.startPrank(gov);
        address(staking).call{value: 1 ether}("");
        wag.mint(alice, 10 ether);
        wag.mint(bob, 10 ether);
        wag.mint(cletus, 10 ether);
        vm.stopPrank();
    }

    function testConstructor() public {
        assertEq(address(staking.wagToken()), address(wag));
        assertEq(staking.governance(), gov);
        assertEq(staking.rewardRate(), REWARD_RATE);
        assertEq(address(staking).balance, 1 ether);
    }

    function testDepositStake() public {
        vm.startPrank(alice);
        wag.approve(address(staking), 10 ether);
        staking.depositStake(5 ether);
        uint256 blocky = block.timestamp;
        vm.stopPrank();

        assertEq(wag.balanceOf(alice), 5 ether);
        assertEq(staking.getStaker(alice).stakedAmount, 5 ether);
        assertEq(staking.getStaker(alice).rewardDebt, 0);
        assertEq(staking.totalRewardDebt(), 0);
        assertEq(staking.totalShares(), 5 ether);
        assertEq(staking.timeLastAllocation(), blocky);
        assertEq(staking.rewardRate(), REWARD_RATE);
        assertEq(staking.accumulatedRewardPerShare(), 0);

        uint256 timeWarp = 100;
        vm.warp(block.timestamp + timeWarp);
        vm.prank(alice);
        staking.depositStake(5 ether);
        blocky = block.timestamp;
        uint256 expectedAccumulatedRewardPerShare = REWARD_RATE * timeWarp * 1e18 / 5 ether;

        // TODO: test alice's MATIC balance update. how do you do this and account for gas spent on depositStake?
        assertEq(wag.balanceOf(alice), 0);
        assertEq(staking.getStaker(alice).stakedAmount, 10 ether);
        assertEq(staking.getStaker(alice).rewardDebt, expectedAccumulatedRewardPerShare * 10 ether / 1e18);
        assertEq(staking.totalRewardDebt(), expectedAccumulatedRewardPerShare * 10 ether / 1e18);
        assertEq(staking.totalShares(), 10 ether);
        assertEq(staking.timeLastAllocation(), blocky);
        assertEq(staking.rewardRate(), REWARD_RATE);
        assertEq(staking.accumulatedRewardPerShare(), expectedAccumulatedRewardPerShare);
    }

    function testWithdrawStake() public {
        vm.startPrank(alice);
        wag.approve(address(staking), 10 ether);
        staking.depositStake(10 ether);
        uint256 blocky = block.timestamp;
        vm.stopPrank();
    }
}
