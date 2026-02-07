// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RewardToken.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Crowdfunding is ReentrancyGuard {
    struct Campaign {
        uint256 campaignId;
        string title;
        address creator;
        uint256 fundingGoal;
        uint256 deadline;
        uint256 totalRaised;
        bool finalized;
        bool deleted;
    }

    RewardToken public rewardToken;
    uint256 public constant REWARD_RATE = 100;
    uint256 public campaignCount;

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event CampaignCreated(
        uint256 indexed campaignId,
        string title,
        address indexed creator,
        uint256 fundingGoal,
        uint256 deadline
    );
    event ContributionMade(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );
    event CampaignFinalized(
        uint256 indexed campaignId,
        uint256 totalRaised,
        bool goalMet
    );
    event CampaignCancelled(
        uint256 indexed campaignId,
        address indexed creator
    );
    event TokensMinted(address indexed recipient, uint256 amount);

    constructor(address _rewardTokenAddress) {
        rewardToken = RewardToken(_rewardTokenAddress);
    }

    function createCampaign(
        string memory _title,
        uint256 _goalWei,
        uint256 _durationSeconds
    ) external {
        require(_goalWei > 0, "Goal must be greater than 0");
        require(_durationSeconds > 0, "Duration must be greater than 0");

        uint256 campaignId = campaignCount;
        uint256 deadline = block.timestamp + _durationSeconds;

        campaigns[campaignId] = Campaign({
            campaignId: campaignId,
            title: _title,
            creator: msg.sender,
            fundingGoal: _goalWei,
            deadline: deadline,
            totalRaised: 0,
            finalized: false,
            deleted: false
        });

        campaignCount++;

        emit CampaignCreated(
            campaignId,
            _title,
            msg.sender,
            _goalWei,
            deadline
        );
    }

    function contribute(uint256 _campaignId) external payable nonReentrant {
        Campaign storage campaign = campaigns[_campaignId];

        require(!campaign.deleted, "Campaign has been cancelled");
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(!campaign.finalized, "Campaign is finalized");
        require(msg.value > 0, "Contribution must be greater than 0");

        campaign.totalRaised += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        uint256 tokenAmount = msg.value * REWARD_RATE;

        try rewardToken.mint(msg.sender, tokenAmount) {
            emit TokensMinted(msg.sender, tokenAmount);
        } catch {
            revert("Token minting failed");
        }
        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    function cancelCampaign(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];

        require(msg.sender == campaign.creator, "Only creator can cancel");
        require(!campaign.finalized, "Campaign already finalized");
        require(!campaign.deleted, "Campaign already cancelled");
        require(
            campaign.totalRaised == 0,
            "Cannot cancel: funds already raised"
        );

        campaign.deleted = true;

        emit CampaignCancelled(_campaignId, msg.sender);
    }

    function finalizeCampaign(uint256 _campaignId) external nonReentrant {
        Campaign storage campaign = campaigns[_campaignId];

        require(!campaign.deleted, "Campaign has been cancelled");
        require(
            block.timestamp >= campaign.deadline,
            "Campaign has not ended yet"
        );
        require(!campaign.finalized, "Campaign already finalized");

        campaign.finalized = true;

        if (campaign.totalRaised > 0) {
            (bool success, ) = campaign.creator.call{
                value: campaign.totalRaised
            }("");
            require(success, "Transfer to creator failed");
        }

        emit CampaignFinalized(
            _campaignId,
            campaign.totalRaised,
            campaign.totalRaised >= campaign.fundingGoal
        );
    }

    function getCampaign(
        uint256 _campaignId
    ) external view returns (Campaign memory) {
        return campaigns[_campaignId];
    }
}
