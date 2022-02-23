// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./BonoboReferral.sol";
import "./BonoboMint.sol";

contract Bonobo is BonoboMint, BonoboReferral {
    // uint256 private PRICE = 100000000000000000; //0.1ETH
    uint256 private CLAIM_RATE = 20000000000000000; //0.02ETH //PASS THIS IN FROM CONSTRUCTOR
    uint256 private CLAIM_WAIT_TIME = 0; //Blocks

    bool public pauseClaimReward = true; //paused by default

    // constructor(string memory _contractName, string memory _tokenSymbol) BonoboMint(_contractName, _tokenSymbol) {}

    constructor(
        // string memory _uri,
        string memory _contractName,
        string memory _tokenSymbol
    )
        // uint256 _maxMint,
        // uint256 _maxMintPerTx
        BonoboMint(_contractName, _tokenSymbol)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        // MAX_MINT = _maxMint;
        // MAX_MINT_PER_TX = _maxMintPerTx;
        // baseTokenURI = _uri;
    }

    function refer(address _referee) public {
        //Put a flag to pause refer
        require(_referee == address(_referee), "Invalid Address"); //Check if Address is valid
        require(isAMinter[msg.sender] == true, "Not Minter"); // Check if the account trying to refer has minted any NFT yet?
        require(isAMinter[_referee] == false, "Already Minter"); // Check that the account referred has not minted yet
        require(refereeStruct[_referee].isValid == false, "Already Referred"); //is already referred
        require(_referee != msg.sender, "Cannot Refer itself"); //cannot refer itself
        _refer(_referee);
    }

    // Add Referall logic here.
    // Account who already minted sends Referall link(code) to referee
    //Referee click the link(enter in the UI)
    //Web3 getTransaction determines the address of the person referring
    // if _referBy is blank, mint is as a normalm mint - not a referall

    function mintNFT(uint256 _quantity) public payable {
        require(_quantity > 0, "INVALID QUANTITY");
        require(getNFTPrice() * _quantity == msg.value, "INCORRECT ETH AMOUNT");
        require(saleIsActive, "SALE INACTIVE");
        require(_quantity <= MAX_MINT_PER_TX, "EXCEED MINT LIMIT");
        require(totalSupply() + _quantity <= MAX_MINT, "EXCEEDS MAX SUPPLY");

        mintnft(_quantity);

        isAMinter[msg.sender] = true;
        referredByStruct[msg.sender].countMinted = referredByStruct[msg.sender].countMinted + _quantity;
        updateReferral(_quantity);
    }

    function claimReferralRewards() public {
        require(pauseClaimReward == false, "Claim paused"); //if paused stop
        //add checkto see if msg.sender refers anyone at all
        require(referredByStruct[msg.sender].countReferredMinted != 0, "Not eligible");
        require(referredByStruct[msg.sender].countRewardClaimable != 0, "No rewards");
        require(referredByStruct[msg.sender].mostRecentClaimBlock + CLAIM_WAIT_TIME <= block.number, "Need to wait"); //Claim is available after 60000 ~ (10 days) blocks since last claim

        //Withdraw from contract
        (bool success, ) = msg.sender.call{value: getAmountClaimable()}("");
        require(success, "Failed");

        referredByStruct[msg.sender].timesRewardClaimed = referredByStruct[msg.sender].timesRewardClaimed + 1;
        referredByStruct[msg.sender].mostRecentClaimBlock = block.number;
        referredByStruct[msg.sender].countRewardClaimable = 0; //reset number claimable
    }

    function getNFTPrice() public view returns (uint256) {
        if (refereeStruct[msg.sender].isValid == true) {
            //if the account is a referred account
            return 90000000000000000; // 0.09 ETH - Discounted Price for referred
        } else return 100000000000000000; // 0.1 ETH - Original Price
    }

    function getAmountClaimable() public view returns (uint256) {
        return CLAIM_RATE * referredByStruct[msg.sender].countRewardClaimable;
    }

    function pauseClaimRewards() public onlyOwner {
        pauseClaimReward = true;
    }

    function unpauseClaimRewards() public onlyOwner {
        pauseClaimReward = false;
    }

    function withdraw(address payable _to) public onlyOwner {
        uint256 balance = address(this).balance;

        (bool success, ) = _to.call{value: balance}("");
        require(success, "Failed to send Ether");
    }
}
