// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC3664/ERC3664.sol";

library CharacterType{
    
    uint256 public constant CHARACTER_NFT_NUMBER = 1;
    uint256 public constant WEAPON_NFT_NUMBER = 2;
    uint256 public constant ARMOR_NFT_NUMBER = 3;

    struct SynthesizedToken {
        address owner;
        uint256 id;
    }
}