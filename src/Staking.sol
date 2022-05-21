// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public wagToken;
    address public governance;
    uint256 public rewardRate;
    uint256 public accumulatedRewardPerShare;
    uint256 public rewardBalance;
    uint256 public timeLastAllocation;
    uint256 public timeFirstAllocation;
    uint256 public totalShares;
    uint256 public totalRewardDebt;

    mapping(address => Staker) public stakers;

    struct Staker {
        uint256 stakedAmount;
        uint256 rewardDebt;
    }

    constructor(address _wagToken, uint256 _rewardRate, address _governance) {
        wagToken = IERC20(_wagToken);
        governance = _governance;
        rewardRate = _rewardRate;
    }

    function changeGovernanceAddress(address _newGovernance) external {
        require(msg.sender == governance, "Only governance can change the governance address");
        governance = _newGovernance;
    }

    function changeRewardRate(uint256 _newRewardRate) external {
        require(msg.sender == governance, "Only governance can change the reward rate");
        _updateRewards();
        rewardRate = _newRewardRate;
    }

    function depositStake(uint256 _amount) public {
        require(wagToken.transferFrom(msg.sender, address(this), _amount));
        _updateRewards();
        Staker storage _staker = stakers[msg.sender];
        uint256 _pendingReward;
        if(_staker.stakedAmount > 0) {
            _pendingReward = _staker.stakedAmount * accumulatedRewardPerShare / 1e18 - _staker.rewardDebt;
        }
        _staker.stakedAmount += _amount;
        totalRewardDebt -= _staker.rewardDebt;
        _staker.rewardDebt = _staker.stakedAmount * accumulatedRewardPerShare / 1e18;
        totalRewardDebt += _staker.rewardDebt;
        totalShares += _amount;
        if(_pendingReward > 0) {
            msg.sender.call{value: _pendingReward}("");
        }
    }

    function withdraw(uint256 _amount) external {
        Staker storage _staker = stakers[msg.sender];
        require(_staker.stakedAmount >= _amount, "Insufficient staked balance");
        _updateRewards();
        uint256 _pendingReward = _staker.stakedAmount * accumulatedRewardPerShare / 1e18 - _staker.rewardDebt;
        _staker.stakedAmount -= _amount;
        totalRewardDebt -= _staker.rewardDebt;
        _staker.rewardDebt = _staker.stakedAmount * accumulatedRewardPerShare / 1e18;
        totalRewardDebt += _staker.rewardDebt;
        wagToken.transfer(msg.sender, _amount);
        totalShares -= _amount;
        if (_pendingReward > 0) {
            msg.sender.call{value: _pendingReward}("");
        }
    }

    function getPendingRewardsByStaker(address _staker) public view returns(uint256) {
        return (stakers[_staker].stakedAmount * getNewAccumulatedRewardPerShare()/1e18 - stakers[_staker].rewardDebt);
    }

    function getNewAccumulatedRewardPerShare() public view returns(uint256) {
        return (accumulatedRewardPerShare + (block.timestamp - timeLastAllocation) * rewardRate * 1e18 / totalShares);
    }

    function _contributeStakingRewards() internal {
        _updateRewards();
        rewardBalance = address(this).balance;
    }

    function _updateRewards() internal {
        if(timeLastAllocation == block.timestamp) {
            return;
        }
        if(totalShares == 0) {
            timeLastAllocation = block.timestamp;
            timeFirstAllocation = block.timestamp;
            return;
        }
        uint256 _newAccumulatedRewardPerShare = accumulatedRewardPerShare + (block.timestamp - timeLastAllocation) * rewardRate * 1e18 / totalShares;
        uint256 _accumulatedReward = _newAccumulatedRewardPerShare * totalShares / 1e18 - totalRewardDebt;
        if (_accumulatedReward >= rewardBalance) {
            accumulatedRewardPerShare += (rewardBalance - (accumulatedRewardPerShare * totalShares - totalRewardDebt)) * 1e18 / totalShares;
            rewardRate = 0; 
        } else {
            accumulatedRewardPerShare = _newAccumulatedRewardPerShare;
        }
        timeLastAllocation = block.timestamp;
    }

    fallback() external payable {
        if(msg.value > 0) {
            _contributeStakingRewards();
        }
    }
}
