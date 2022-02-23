// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract BonoboReferral {
    struct ReferBy {
        uint256 countMinted; //Count minted by ReferBy
        uint256 countReferred; //Count referred by ReferBy
        uint256 countReferredMinted; //Count Minted by referee
        uint256 countRewardClaimable; // available to claim  count
        uint256 timesRewardClaimed; //count for which reward is already claimed
        uint256 mostRecentClaimBlock; //Block Number when last claim was made
        address[] referee;
    }

    struct Referee {
        address referredBy;
        // uint256 countMinted; //count minted by Referee
        bool isValid; //To make sure the Referee Exist
    }

    mapping(address => ReferBy) public referredByStruct;
    mapping(address => Referee) public refereeStruct;

    //mapping(address => bool) public isAMinter; //  SIMILATION for this. This should be declared in the main NFT Contract. Track if an address is a minter to check if eligible to refer anyone

    function getRefereeList(address _referredby) public view returns (address[] memory) {
        return referredByStruct[_referredby].referee;
    }

    // function getReferralCount() public view returns (uint ) {
    //     return referees.length;
    // }

    /// Call this function when the person refers any new addresses.
    //TODO: Can change functiuon parameter _referee to an arry so that user can refer multiple address in 1 transaction
    //This functions should be called by any referrals.
    function _refer(address _referee) internal {
        referredByStruct[msg.sender].countReferred = referredByStruct[msg.sender].countReferred + 1;
        referredByStruct[msg.sender].referee.push(_referee);
        refereeStruct[_referee].referredBy = msg.sender;
        refereeStruct[_referee].isValid = true;
    }

    //Put this function inside the mint
    function updateReferral(uint256 _quantity) internal {
        //require quantity !=0!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //
        //Check if address is from a RefereeList
        if (refereeStruct[msg.sender].isValid == true) {
            address referredBy = refereeStruct[msg.sender].referredBy;
            // refereeStruct[msg.sender].countMinted = refereeStruct[msg.sender].countMinted + _quantity;
            referredByStruct[referredBy].countReferredMinted =
                referredByStruct[referredBy].countReferredMinted +
                _quantity;
            referredByStruct[referredBy].countRewardClaimable =
                referredByStruct[referredBy].countRewardClaimable +
                _quantity;
        }
    }
}
