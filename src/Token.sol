// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address public governance;

    constructor(address _governance) public ERC20("WAG Token", "WAG") {
        governance = _governance;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == governance, "Only governance can mint");
        _mint(account, amount);
    }

    function changeGovernanceAddress(address _newGovernance) external {
        require(msg.sender == governance, "Only governance can change the governance address");
        governance = _newGovernance;
    }
}
