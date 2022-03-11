// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract HeroesOnChain is ERC721Enumerable, Ownable {
    constructor() ERC721("Heroes on Chain", "HOC") {}

    using Strings for uint256;
    uint256 public maxTotalSupply = 100;
    string[3] public classes = ["Warrior", "Healer", "Mage"];

    mapping(uint256 => Hero) public Heroes;
    struct Hero {
        string name;
        uint256 heroClassId;
        string class;
        uint256 magic;
        uint256 intelect;
        uint256 strength;
        uint256 health;
        uint256 dexterity;
    }

    function generateRandom() public view virtual returns (uint256) {
        uint256 num = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        );
        return num;
    }

    function mint() public payable {
        uint256 tokenIds = totalSupply();
        if (msg.sender != owner()) {
            require(msg.value >= 0.05 ether, "Price of nft is 0.05 ether");
        }
        require(tokenIds + 1 <= maxTotalSupply, "Sold out");

        uint256[] memory stats = new uint256[](5);

        stats[0] = 0;
        stats[1] = 5;
        stats[2] = 10;
        stats[3] = 15;
        stats[4] = 20;

        uint256 len = 5;
        uint256 hero;

        do {
            uint256 pos = generateRandom() % len;
            uint256 value = (generateRandom() % (13 + len)) + 1;
            len--;
            hero |= value << stats[pos];
            stats[pos] = stats[len];
        } while (len > 0);

        Heroes[tokenIds + 1] = generateHero(hero, tokenIds + 1);
        _safeMint(msg.sender, tokenIds + 1);
    }

    function generateHero(uint256 _hero, uint256 _tokenId)
        internal
        view
        returns (Hero memory)
    {
        uint256 heroIndex = generateRandom() % 3;

        Hero memory newHero = Hero(
            string(abi.encodePacked("HOC #", _tokenId.toString())),
            heroIndex + 1,
            classes[heroIndex],
            uint256(_hero & 0x1F),
            uint256((_hero >> 5) & 0x1F),
            uint256((_hero >> 10) & 0x1F),
            uint256((_hero >> 15) & 0x1F),
            uint256((_hero >> 20) & 0x1F)
        );
        return newHero;
    }

    function buildMetaData(uint256 _tokenId)
        internal
        view
        returns (string memory)
    {
        //Get the correct Hero obj for the tokenId
        Hero memory selectedHero = Heroes[_tokenId];
        string memory description = "First On Chain NFT";
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                selectedHero.name,
                                '", "description":"',
                                description,
                                '", "image":"',
                                getImage(_tokenId),
                                '","attributes": [{"trait_type":"Class", "value":"',
                                selectedHero.class,
                                '"},{"trait_type":"Magic", "value":"',
                                selectedHero.magic.toString(),
                                '"}, {"trait_type":"Intelect", "value":"',
                                selectedHero.intelect.toString(),
                                '"}, {"trait_type":"Strength", "value":"',
                                selectedHero.strength.toString(),
                                '"}, {"trait_type":"Health", "value":"',
                                selectedHero.health.toString(),
                                '"}, {"trait_type":"Health", "value":1}]}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return buildMetaData(_tokenId);
    }

    function getImage(uint256 _tokenId) internal pure returns (string memory) {
        string
            memory baseURI = "ipfs://QmenaK545QED83x68H6sqWMNm4ecmMjiYJcYkiSWq8bgcS/";
        string memory imageURI = string(
            abi.encodePacked(baseURI, _tokenId.toString(), ".png")
        );
        return imageURI;
    }
}
