// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.10;

contract OracleMock {
    function getCurrentValue(bytes32) public view returns (bytes32) {
        return blockhash(block.number - 1);
    }
}
