// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PaymentToken is ERC20 {
    constructor() ERC20("PaymentToken", "PT") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
   
}