// contracts/Creatures.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BonoboMint is ERC721Enumerable, ERC721Burnable, Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    mapping(address => bool) public isAMinter;
    bool public saleIsActive = false;

    uint256 public MAX_MINT = 300;
    uint256 public MAX_MINT_PER_TX = 30;
    // uint256 public PRICE = 100000000000000000; //0.1ETH
    string private baseTokenURI;

    constructor(string memory _contractName, string memory _tokenSymbol)
        // uint256 _maxMint,
        // uint256 _maxMintPerTx
        ERC721(_contractName, _tokenSymbol)
    {
        // _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        // MAX_MINT = _maxMint;
        // MAX_MINT_PER_TX = _maxMintPerTx;
        // baseTokenURI = _uri;
    }

    // constructor(
    //     string memory _uri,
    //     string memory _contractName,
    //     string memory _tokenSymbol,
    //     uint256 _maxMint,
    //     uint256 _maxMintPerTx
    // ) ERC721(_contractName, _tokenSymbol) {
    //     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    //     MAX_MINT = _maxMint;
    //     MAX_MINT_PER_TX = _maxMintPerTx;
    //     baseTokenURI = _uri;
    // }

    function mintnft(uint256 _quantity) internal {
        for (uint256 i = 0; i < _quantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_MINT) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    // function getNFTPrice() public view returns (uint256) {
    //     require(saleIsActive, "SALE IS NOT ACTIVE");
    //     require(totalSupply() < MAX_MINT, "MAX SUPPLY REACHED");

    //     uint256 currentSupply = totalSupply();

    //     if (currentSupply >= 9500) {
    //         return 120000000000000000; // 9000 - 9499 0.12 ETH
    //     } else if (currentSupply >= 9) {
    //         return 100000000000000000; // 7000 - 8999 0.1 ETH
    //     } else if (currentSupply >= 7) {
    //         return 90000000000000000; // 5000  - 6999 0.09 ETH
    //     } else if (currentSupply >= 5) {
    //         return 80000000000000000; // 5000 - 6999 0.08 ETH
    //     } else if (currentSupply >= 3) {
    //         return 70000000000000000; // 3000 - 4999 0.07 ETH
    //     } else if (currentSupply >= 1) {
    //         return 60000000000000000; // 1000 - 2999 0.06 ETH
    //     } else {
    //         return 50000000000000000; // 0 - 999 0.05 ETH
    //     }
    // }

    function toggleSaleFlag() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string calldata uri) public onlyOwner {
        baseTokenURI = uri;
    }

    /**
     * @notice Returns a list of all tokenIds assigned to an address
     * Taken from https://ethereum.stackexchange.com/questions/54959/list-erc721-tokens-owned-by-a-user-on-a-web-page
     * @param user get tokens of a given user
     */
    function tokensOfOwner(address user) external view returns (uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(user);

        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory output = new uint256[](tokenCount);

            for (uint256 index = 0; index < tokenCount; index++) {
                output[index] = tokenOfOwnerByIndex(user, index);
            }

            return output;
        }
    }

    function setMinters(address[] memory _addresses) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            grantRole(MINTER_ROLE, _addresses[i]);
        }
    }

    function mintGiveaways(address[] memory _addresses) public onlyOwner {
        require(totalSupply() < MAX_MINT, "MAX SUPPLY REACHED");

        for (uint256 i = 0; i < _addresses.length; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_MINT) {
                _safeMint(_addresses[i], mintIndex);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
