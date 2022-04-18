// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.10;

interface Oracle {
    function rng() external view returns (bytes32);
}

contract DollarAuction {
    uint256 public roundEnd;
    uint256 public roundLength;
    uint256 public minBid;
    uint256 public maxBid;
    uint256 public winnerPayoutPercent;
    uint256 public stakingRewardsPercent;
    address public admin;
    uint256 public adminFee;
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
        uint256 _adminFee,
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
        require(_adminFee < 100);
        minBid = _minBid;
        maxBid = _maxBid;
        roundLength = _roundLength;
        winnerPayoutPercent = _winnerPayoutPercent;
        stakingRewardsPercent = _stakingRewardsPercent;
        admin = _admin;
        adminFee = _adminFee;
        token = _token;
        staking = _staking;
        oracle = _oracle;
    }

    function bid() external payable {
        require(msg.value > bidderBalances[bidders[4]]);
        address lowestBidder = bidders[0];
        for (uint256 i = 0; i < bidders.length; i++) {
            bidders[i] = bidders[i + 1];
        }
        bidders[4] = msg.sender;
        adminFees += msg.value * (adminFee / 100);
        // Give one WAG to the bidder
        // token.transfer(msg.sender, 1e18);
        // Pay back bidder no longer in top 5
        (bool sent, ) = lowestBidder.call{value: bidderBalances[lowestBidder]}(
            ""
        );
        require(sent, "Failed to pay back lowest bidder");
    }

    function roundOver() external {
        require(block.timestamp > roundEnd);
        bytes32 randomVal = Oracle(oracle).rng();
        uint256 randIdx = uint256(randomVal) % 3;
        // Add up random sacrificial bidder and 2nd highest bidder balances
        uint256 sacrificalBidsTotal = bidderBalances[bidders[randIdx]] +
            bidderBalances[bidders[3]];
        // Adds random loser's bid to staking rewards / admin fees
        stakingRewards += sacrificalBidsTotal * (stakingRewardsPercent / 100);
        adminFees += sacrificalBidsTotal - stakingRewards;
        // Pays back bidders not chosen from place 3-5
        for (uint256 i = 0; i < 2; i++) {
            if (i != randIdx) {
                (bool sent, ) = bidders[i].call{
                    value: bidderBalances[bidders[i]]
                }("");
                require(sent, "Failed to pay back bidders");
            }
        }
        // Pay admin
        (bool sentAdmin, ) = admin.call{value: adminFees}("");
        require(sentAdmin, "Failed to pay admin");
        // Transfer staking rewards to staking contract
        (bool sentStaking, ) = staking.call{value: stakingRewards}("");
        require(sentStaking, "Failed to transfer staking rewards");
        // Pay winner
        (bool sentWinner, ) = bidders[4].call{
            value: bidderBalances[bidders[4]]
        }("");
    }

    // Accept donations to the pot
    receive() external payable {}
}
