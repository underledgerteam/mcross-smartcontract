// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IMCrossNFT {
    function crossMint(
        address _minter,
        uint256 _mintAmount,
        address _caller,
        uint256 _amount
    ) external;
}
