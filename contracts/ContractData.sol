// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataGenerator {
    //"transfer(address,uint256)"
    function getTransferData(string memory functionSignature, address _to, uint256 _value) public pure returns (bytes memory) {
        return abi.encodeWithSignature( functionSignature, _to, _value);
    }
}

contract TokenCaller {
    function callTransfer(address tokenContract, address to, uint256 value) public returns (bool) {
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, value);
        (bool success, ) = tokenContract.call(data);
        return success;
    }
}