// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    address public crowdfundingContract;

    constructor() ERC20("CrowdReward", "CWD") Ownable(msg.sender) {}

    function setCrowdfundingContract(address _crowdfundingContract) external onlyOwner {
        crowdfundingContract = _crowdfundingContract;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner() || msg.sender == crowdfundingContract, "RewardToken: Caller is not authorized to mint");
        _mint(to, amount);
    }
}
