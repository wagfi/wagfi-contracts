// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.10;

contract OracleMock {
    function getCurrentValue(bytes32 queryId)
        public
        view
        returns (bytes memory)
    {
        return abi.encode(blockhash(block.number - 1));
    }
}
