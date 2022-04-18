// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.10;

contract DollarAuction {
    uint256 public roundEnd;
    uint256 public roundLength;
    uint256 public minBid;
    uint256 public maxBid;
    uint256 public winnerPayoutPercent;
    uint256 public stakingRewardsPercent;
    address public admin;
    address public token;
    address public staking;
    address public oracle;
    address[5] public bidders;
    uint256 public adminFees;
    mapping(address => uint256) public bidderBalances;

    constructor(
        uint256 _minBid,
        uint256 _maxBid,
        uint256 _roundLength,
        uint256 _winnerPayoutPercent,
        uint256 _stakingRewardsPercent,
        address _admin,
        address _token,
        address _staking,
        address _oracle
    ) {
        require(_minBid > 0);
        require(_maxBid > minBid);
        require(_roundLength > 60 * 60);
        require(_winnerPayoutPercent > 0);
        require(_stakingRewardsPercent > 0);
        require(_winnerPayoutPercent + _stakingRewardsPercent < 100);
        minBid = _minBid;
        maxBid = _maxBid;
        roundLength = _roundLength;
        winnerPayoutPercent = _winnerPayoutPercent;
        stakingRewardsPercent = _stakingRewardsPercent;
        admin = _admin;
        token = _token;
        staking = _staking;
        oracle = _oracle;
    }

    function bid() external payable {
        require(msg.value > bidderBalances[bidders[4]]);
        for (uint256 i = 0; i < bidders.length; i++) {
            bidders[i] = bidders[i + 1];
        }
        bidders[4] = msg.sender;
        // Add fee to total admin fees
        // Give one WAG to the bidder
        // token.transfer(msg.sender, 1e18);
        // Pay back bidder no longer in top 5
        // transfer(bidders[0], bidderBalances[bidders[0]]);
    }

    function roundOver() external {
        require(block.timestamp > roundEnd);
        // Get random val from oracle
        // Pick random loser from place 3-5
        // Adds random loser's bid to staking rewards / admin fees
        // Pays back bidders not chosen from place 3-5
        // Adds 2nd place bidder's bid to staking rewards / admin fees
        // calls payout function
    }

    function payout() internal {
        // Sends admin fees
        // transfer(admin, adminFees);
        // Sends staking rewards to Staking contract
        // transfer(staking, stakingRewards);
        // Sends winner payout
        // transfer(bidders[4], winnerPayout);
    }

    // Accept donations to the pot
    receive() external payable {}
}
