// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.10;

contract DollarAuction {
    
    uint256 public endTime;
    uint256 public roundLength;
    uint256 public roundNumber;
    uint256 public minBid;
    uint256 public maxBid;
    uint256 public currentBid;
    uint256 public winnerPayoutPercent;
    uint256 public admin;
    address public token;
    address public staking;
    address public oracle;
    address[5] public bidders;
    uint256 public adminFees;
    mapping(address => uint256) public bidderBalances;


    constructor (
        uint256 _minBid,
        uint256 _maxBid,
        uint256 _roundLength,
        uint256 _winnerPayoutPercent,
        address _admin,
        address _token,
        address _staking,
        address _oracle,
    ) {
        minBid = _minBid;
        maxBid = _maxBid;
        roundLength = _roundLength;
        winnerPayoutPercent = _winnerPayoutPercent;
        admin = _admin;
        token = _token;
        staking = _staking;
        oracle = _oracle;
    }

    function bid() external payable {
        require (msg.value > currentBid);
        for (uint256 i=0; i<bidders.length; i++) {
            bidders[i] = bidders[i+1];
        }
        bidders[4] = msg.sender;
        // add fee to total admin fees
        // give one WAG to the bidder
        token.transfer(msg.sender, 1e18);
    }

    function roundOver() external {
        require (block.timestamp > endTime);
        // Get random val from oracle
        // Pick random loser from place 3-5
        // Adds random loser total bid 
        // calls payout function
    }

    function payout() internal {
        // checks if auction over
        // Sends admin fees
        // Sends staking rewards to Staking contract
        // Sends winner payout
    }

    // Accept donations to the pot
    function receive() external payable {}


}
