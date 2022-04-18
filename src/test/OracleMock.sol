// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.10;

contract OracleMock {
    constructor() public {}

    function rng() public view returns (bytes32) {
        return blockhash(block.number - 1);
    }
}
