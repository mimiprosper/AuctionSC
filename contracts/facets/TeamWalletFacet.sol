// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeamWalletFacet {
    address public teamWallet;

    function setTeamWallet(address _teamWallet) external {
        teamWallet = _teamWallet;
    }

    function distributeFee(uint256 totalFee) external {
        require(teamWallet != address(0), "Team wallet not set");

        uint256 teamFee = totalFee * 2 / 100; // 2% of totalFee
        payable(teamWallet).transfer(teamFee);
    }
}
