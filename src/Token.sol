// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Token is IERC20 {
    string public constant name = "WAG Token";
    string public constant symbol = "WAG";
    uint8 public constant decimals = 18;
    uint256 totalSupply_;
    address public owner;

    mapping(address => uint256) balances;

    constructor(uint256 total) public {
        owner = msg.sender;
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint");
        require(amount > 0, "Amount must be greater than 0");
        require(account != address(0), "Receiver is 0 address");

        balances[account] += amount;
        totalSupply_ += amount;
    }
}
