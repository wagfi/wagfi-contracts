// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() public ERC20("WAG Token", "WAG") {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
