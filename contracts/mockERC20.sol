//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETHMOCK is ERC20 {
    constructor() ERC20("WETH", "WETH") {
        _mint(address(this), 10000000000000000000000000000000);
    }

    function mint(address _user, uint256 _amount) external {
        _mint(_user, _amount);
    }
}
