// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BurnFacet {
    function burn(address token, uint256 amount) external {
        ERC20(token).transfer(address(0), amount);
    }
}
