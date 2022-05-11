// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./ERC3664/ERC3664.sol";

contract Character is ERC3664, ERC721Enumerable, Ownable {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC3664, ERC721Enumerable)
        returns (bool)
    {
        return
            // interfaceId == type(ISynthetic).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    uint256 public constant CHARACTER_NFT_NUMBER = 1;
    uint256 public constant WEAPON_NFT_NUMBER = 2;
    uint256 public constant ARMOR_NFT_NUMBER = 3;

    string private _name = "Character";
    string private _symbol = "CHR";

    bool private _isSalesActive;

    uint256 public _totalSupply = 8000;

    struct SynthesizedToken {
        address owner;
        uint256 id;
    }

    // mainToken => SynthesizedToken
    mapping(uint256 => SynthesizedToken[]) public synthesizedTokens;

    constructor() ERC721(_name, _symbol) Ownable() {
        _mint(CHARACTER_NFT_NUMBER, "CHARACTER", "character", "");
        _isSalesActive = true;
    }

    function mint(address to, uint256 tokenId) external payable {
        require(_isSalesActive, "Not yet");
        require(msg.value == 0.005 ether, "no enough eth to mint");

        _safeMint(to, tokenId);
        _afterTokenMint(tokenId);
    }

    function getSubTokens(uint256 tokenId)
        public
        view
        returns (uint256[] memory)
    {
        SynthesizedToken[] storage tokens = synthesizedTokens[tokenId];
        uint256[] memory subs = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            subs[i] = tokens[i].id;
        }
        return subs;
    }

    function combine(uint256 tokenId, uint256[] calldata subIds) public {
        require(ownerOf(tokenId) == _msgSender(), "caller is not token owner");
        require(
            primaryAttributeOf(tokenId) == CHARACTER_NFT_NUMBER,
            "only support primary token been combine"
        );

        for (uint256 i = 0; i < subIds.length; i++) {
            require(
                ownerOf(subIds[i]) == _msgSender(),
                "caller is not sub token owner"
            );
            uint256 nft_attr = primaryAttributeOf(subIds[i]);
            require(
                nft_attr != CHARACTER_NFT_NUMBER,
                "not support combine between primary token"
            );
            for (uint256 j = 0; j < synthesizedTokens[tokenId].length; j++) {
                uint256 id = synthesizedTokens[tokenId][j].id;
                require(
                    nft_attr != primaryAttributeOf(id),
                    "duplicate sub token type"
                );
            }
            _transfer(_msgSender(), address(this), subIds[i]);
            synthesizedTokens[tokenId].push(
                SynthesizedToken(_msgSender(), subIds[i])
            );
        }
    }

    function separate(uint256 tokenId) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller is not token owner nor approved"
        );
        require(
            primaryAttributeOf(tokenId) == CHARACTER_NFT_NUMBER,
            "only support primary token separate"
        );

        SynthesizedToken[] storage subs = synthesizedTokens[tokenId];
        require(subs.length > 0, "not synthesized token");
        for (uint256 i = 0; i < subs.length; i++) {
            _transfer(address(this), subs[i].owner, subs[i].id);
        }
        delete synthesizedTokens[tokenId];
    }

    function separateOne(uint256 tokenId, uint256 subId) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller is not token owner nor approved"
        );
        require(
            primaryAttributeOf(tokenId) == CHARACTER_NFT_NUMBER,
            "only support primary token separate"
        );

        uint256 idx = findByValue(synthesizedTokens[tokenId], subId);
        SynthesizedToken storage token = synthesizedTokens[tokenId][idx];
        _transfer(address(this), token.owner, token.id);
        removeAtIndex(synthesizedTokens[tokenId], idx);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (primaryAttributeOf(tokenId) == CHARACTER_NFT_NUMBER) {
            SynthesizedToken[] storage subs = synthesizedTokens[tokenId];
            for (uint256 i = 0; i < subs.length; i++) {
                subs[i].owner = to;
            }
        }
    }

    function _afterTokenMint(uint256 tokenId) internal virtual {
        attach(tokenId, CHARACTER_NFT_NUMBER, 1, bytes("character"), true);
        uint256 id = _totalSupply + (tokenId - 1) * 2 + 1;
        // WEAPON
        mintSubToken(WEAPON_NFT_NUMBER, tokenId, id);
        // ARMOR
        mintSubToken(ARMOR_NFT_NUMBER, tokenId, id + 1);
    }

    function mintSubToken(
        uint256 attr,
        uint256 tokenId,
        uint256 subId
    ) internal virtual {
        _mint(address(this), subId);
        attach(subId, attr, 1, bytes(""), true);
        synthesizedTokens[tokenId].push(SynthesizedToken(_msgSender(), subId));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {}

    function findByValue(SynthesizedToken[] storage values, uint256 value)
        internal
        view
        returns (uint256)
    {
        uint256 i = 0;
        while (values[i].id != value) {
            i++;
        }
        return i;
    }

    function removeAtIndex(SynthesizedToken[] storage values, uint256 index)
        internal
    {
        uint256 max = values.length;
        if (index >= max) return;

        if (index == max - 1) {
            values.pop();
            return;
        }

        for (uint256 i = index; i < max - 1; i++) {
            values[i] = values[i + 1];
        }
        values.pop();
    }
}
