// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardsFacet {
    mapping(address => uint256) public rewards;

    function distributeRewards(address recipient, uint256 amount) external {
        rewards[recipient] += amount;
    }

    function claimReward() external {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No rewards to claim");

        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
