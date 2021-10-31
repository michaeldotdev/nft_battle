// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import "./libraries/Base64.sol";

contract MyNFTBattler is ERC721 {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 currentHP;
        uint256 maxHP;
        uint256 attackDamage;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;

    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

    struct BigBoss {
        string name;
        string imageURI;
        uint256 currentHP;
        uint256 maxHP;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterCurrentHP,
        uint256[] memory characterAttackDamage,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHP,
        uint256 bossAttackDamage
    ) ERC721("Champions", "CHAMP") {
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            currentHP: bossHP,
            maxHP: bossHP,
            attackDamage: bossAttackDamage
        });

        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    currentHP: characterCurrentHP[i],
                    maxHP: characterCurrentHP[i],
                    attackDamage: characterAttackDamage[i]
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.currentHP,
                c.imageURI
            );
        }
        _tokenIds.increment();
    }

    function mintChampionNFT(uint256 _characterIndex) external {
        // Get current tokenId (starts at 1 since we incremented in the constructor).
        uint256 newItemId = _tokenIds.current();

        // The magical function! Assigns the tokenId to the caller's wallet address.
        _safeMint(msg.sender, newItemId);

        // We map the tokenId => their character attributes. More on this in
        // the lesson below.
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            currentHP: defaultCharacters[_characterIndex].currentHP,
            maxHP: defaultCharacters[_characterIndex].currentHP,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strCurrentHP = Strings.toString(charAttributes.currentHP);
        string memory strMaxHP = Strings.toString(charAttributes.maxHP);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game NFT Battler!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strCurrentHP,
                        ', "max_value":',
                        strMaxHP,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];

        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.currentHP,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.currentHP,
            bigBoss.attackDamage
        );

        require(
            player.currentHP > 0,
            "Error: character must have HP to attack boss."
        );

        require(
            bigBoss.currentHP > 0,
            "Error: boss must have HP to attack boss."
        );

        // Allow player to attack boss.
        if (bigBoss.currentHP < player.attackDamage) {
            bigBoss.currentHP = 0;
        } else {
            bigBoss.currentHP = bigBoss.currentHP - player.attackDamage;
        }

        // Allow boss to attack player.
        if (player.currentHP < bigBoss.attackDamage) {
            player.currentHP = 0;
        } else {
            player.currentHP = player.currentHP - bigBoss.attackDamage;
        }

        // Console for ease.
        console.log(
            "Boss attacked player. New player hp: %s\n",
            player.currentHP
        );

        emit AttackComplete(bigBoss.currentHP, player.currentHP);
    }

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        uint256 userNftTokenId = nftHolders[msg.sender];
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
}
