// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PaymentToken1 is ERC20 {
    constructor() ERC20("PaymentToken One", "PT1") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
   
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

}