pragma solidity ^0.8.0;

//  **We want to be able to generate random Hereos.
// **The user gets to put in their class of hereo on generation
// **classes: Mage, Healer, Barbarian
// **Class will not influence stats created, therefore getting an epic hero will be hard.
// **I want to be paid... 0.05 eth per hero!
// I should be able to get my heroes I have generated.
// Heroes should be stored on the chain.
// stats are strength, health, intellect, magic, dexterity
// stats are randomly generated
// A scale of 1 - 18
// The stats are randomly picked and their amplitude is randomly determined according to the following:
// Stat 1 can max at 18
// Stat 2 can max at 17
// Stat 3 can max at 16
// ...
// You could imagine these being an NFT
// They are non divisable

contract Hero {
    event heroCreated(uint256 hero);
    enum Class {
        Mage,
        Healer,
        Barbarian,
        Durid
    }
    mapping(address => uint256[]) addressToHeroes;

    function getHeroes() public view returns (uint256[] memory) {
        return addressToHeroes[msg.sender];
    }

    //Must give the virtual key word to be able to override this function
    function generateRandom() public view virtual returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            );
    }

    function getHeroClass(uint256 hero) public pure returns (uint32) {
        return uint32((hero) & 0x02);
    }

    function getStrength(uint256 hero) public pure returns (uint256) {
        return (hero >> 2) & 0x1F;
    }

    function getHealth(uint256 hero) public pure returns (uint256) {
        return (hero >> 7) & 0x1F;
    }

    function getDex(uint256 hero) public pure returns (uint256) {
        return (hero >> 12) & 0x1F;
    }

    function getIntelect(uint256 hero) public pure returns (uint256) {
        return (hero >> 17) & 0x1F;
    }

    function getMagic(uint256 hero) public pure returns (uint32) {
        return uint32((hero >> 22) & 0x15);
    }

    function createHero(Class class) public payable {
        //Can create this into an erc721 mint function in the future.
        require(
            msg.value >= 0.05 ether,
            "You need to send at least 0.05 to create a hero"
        );
        //Every thing is being stored in bits as its much less storage than if you were to store an object. Use Binary as much as possible to
        // store information .

        uint256[] memory stats = new uint256[](5);

        stats[0] = 2;
        stats[1] = 7;
        stats[2] = 12;
        stats[3] = 17;
        stats[4] = 22;

        uint256 len = 5;
        uint256 hero = uint256(class);

        do {
            //will return a number between  0 - 4
            uint256 pos = generateRandom() % len;
            //will return a number between 1 - 18
            uint256 value = (generateRandom() % (13 + len)) + 1;
            len--;
            //This statement takes the hero uint, adds the binary equivialtent of the value to the position specified by the stats array
            hero |= value << stats[pos];
        } while (len > 0);
        addressToHeroes[msg.sender].push(hero);
        emit heroCreated(hero);
    }

    //A fallback function will catch any call to the conitract that doesnt match any function invocation.
    fallback() external {}
}
