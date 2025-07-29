// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts@4.4.0/token/ERC20/ERC20.sol";

contract ParkingSpaces is ERC20 {
    constructor(address _ownerAddress) ERC20("ParkingSpace", "EDC") {
        _mint(_ownerAddress, 100);
    }
}