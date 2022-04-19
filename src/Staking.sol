// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public wagToken;
    IERC20 public rewardToken;
    address public governance;
    uint256 public rewardRate;
    uint256 public accumulatedRewardPerShare;
    uint256 public timeLastAllocation;
    uint256 public timeFirstAllocation;
    uint256 public totalShares;
    uint256 public totalDebt;

    mapping(address => Staker) public stakers;

    struct Staker {
        uint256 stakedAmount;
        uint256 rewardDebt;
    }

    constructor(address _wagToken, address _rewardToken, uint256 _rewardRate, address _governance) {
        wagToken = IERC20(_wagToken);
        rewardToken = IERC20(_rewardToken);
        governance = _governance;
        rewardRate = _rewardRate;
    }

    function depositStake(uint256 _amount) public {
        require(wagToken.transferFrom(msg.sender, address(this), _amount));
        updateRewards();
        Staker storage _staker = stakers[msg.sender];
        if(_staker.stakedAmount > 0) {
            uint256 _pendingReward = _staker.stakedAmount * accumulatedRewardPerShare / 1e18 - _staker.rewardDebt;
            rewardToken.transfer(msg.sender, _pendingReward);
        }
        _staker.stakedAmount += _amount;
        totalDebt -= _staker.rewardDebt;
        _staker.rewardDebt = _staker.stakedAmount * accumulatedRewardPerShare / 1e18;
        totalDebt += _staker.rewardDebt;
        totalShares += _amount;
    }

    function updateRewards() public {
        if(totalShares == 0) {
            timeLastAllocation = block.timestamp;
            timeFirstAllocation = block.timestamp;
            return;
        }
        if(timeLastAllocation == block.timestamp) {
            return;
        }
        accumulatedRewardPerShare += (block.timestamp - timeLastAllocation) * rewardRate * 1e18 / totalShares;
        timeLastAllocation = block.timestamp;
    }

    function withdraw(uint256 _amount) external {
        Staker storage _staker = stakers[msg.sender];
        require(_staker.stakedAmount >= _amount, "Insufficient staked balance");
        updateRewards();
        uint256 _pendingReward = _staker.stakedAmount * accumulatedRewardPerShare / 1e18 - _staker.rewardDebt;
        rewardToken.transfer(msg.sender, _pendingReward);
        _staker.stakedAmount -= _amount;
        totalDebt -= _staker.rewardDebt;
        _staker.rewardDebt = _staker.stakedAmount * accumulatedRewardPerShare / 1e18;
        totalDebt += _staker.rewardDebt;
        wagToken.transfer(msg.sender, _amount);
        totalShares -= _amount;
    }

    function changeRewardRate(uint256 _rewardRate) external {
        require(msg.sender == governance, "Only governance can change the reward rate");
        updateRewards();
        rewardRate = _rewardRate;
    }

    function getRemainingBalance() public view returns(int256) {
        return (int(rewardToken.balanceOf(address(this)) + totalDebt) - int(getNewAccumulatedRewardPerShare() * totalShares / 1e18));
    }

    function getPendingRewardsByStaker(address _staker) public view returns(uint256) {
        return (stakers[_staker].stakedAmount * getNewAccumulatedRewardPerShare()/1e18 - stakers[_staker].rewardDebt);
    }

    function getNewAccumulatedRewardPerShare() public view returns(uint256) {
        return (accumulatedRewardPerShare + (block.timestamp - timeLastAllocation) * rewardRate * 1e18 / totalShares);
    }
}
