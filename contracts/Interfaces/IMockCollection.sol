// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IMockCollection {
    function mintToken(address _minter, uint256 _tokenId) external;

    function burnToken(uint256 _tokenId) external;
}
