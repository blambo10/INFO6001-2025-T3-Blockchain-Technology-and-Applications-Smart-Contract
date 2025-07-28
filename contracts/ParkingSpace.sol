// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts@4.4.0/token/ERC20/ERC20.sol";

contract ParkingSpace is ERC20 {
    constructor() ERC20("ParkingSpace", "EDC") {
        _mint(msg.sender, 100);
    }

}