pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IHydraS1Verifier.sol";

contract ZKID is ERC721 {
    constructor(address hydraS1Verifier_) ERC721("ZkID", "ZKID") {
        hydraS1Verifier = IHydraS1Verifier(hydraS1Verifier_);
    }

    uint256 supply;
    IHydraS1Verifier hydraS1Verifier;
    // key: nullifier
    mapping (uint256 => bool) isNullifierExpired;
    mapping (uint256 => NFTMetadata) tokenInfo;

    // Define the struct for your NFT's metadata
    struct NFTMetadata {
        uint256 tokenId;
        address owner;
        uint256[] cids;
    }

    // Create a new NFT
    function createCredential(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[5] memory input
    ) external {
        // check proof
        require(!isNullifierExpired[input[4]], "Invalid Nullifier");
        require(hydraS1Verifier.verifyProof(a, b, c, input), "Invalid Proof");
        // mint new token if tokenId
        address mintTo = address(getMintTo(input[0]));
        uint256 tokenId = getTokenId(input[0]);

        if (tokenId == 2 ** 80 - 1) {
            // uint256 tokenId = nfts.length;
            _safeMint(mintTo, supply);
            tokenId = supply;
            tokenInfo[supply].tokenId = supply;
            tokenInfo[supply].owner = mintTo;
            tokenInfo[supply].cids.push(input[2]);

            supply += 1;
        } else {
            require(tokenId < supply, "Invalid TokenId");
            tokenInfo[tokenId].cids.push(input[2]);
        }

        isNullifierExpired[input[4]] = true;
    }

    // Get the metadata of an NFT
    function getNFTMetadata(uint256 _tokenId) external view returns (NFTMetadata memory) {
        require(_exists(_tokenId), "Token ID does not exist");
        return tokenInfo[_tokenId];
    }

    function getMintTo(uint256 number) public pure returns (bytes20) {
        // Shift the uint256 value to the right by 80 bits to get the last 20 bytes
        bytes20 converted = bytes20(uint160(number >> 80));
        return converted;
    }

    function getTokenId(uint256 value) public pure returns (uint256) {
        // Define a mask with the desired bits set to 1
        uint256 mask = uint256(2 ** 80 - 1);

        // Perform a bitwise AND with the mask to get the last 12 bytes
        uint256 result = value & mask;

        return result;
    }

    function getTokenIdByAddress(address owner) public view returns (uint256) {
        for (uint256 i = 0; i < supply; ++i)
            if (tokenInfo[i].owner == owner) return i;

        return uint256(2 ** 80 - 1);
    }
}
