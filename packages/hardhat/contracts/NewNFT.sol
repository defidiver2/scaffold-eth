//SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
/**
 * @title NewNFT
 * ERC1155 implementation with IPFS

VRF contracts: https://docs.chain.link/docs/vrf-contracts



 */




contract NewNFT is ERC1155, IERC1155MetadataURI, AccessControl, VRFConsumerBase {

  bytes32 internal keyHash;
  uint256 internal fee;

  uint256 public randomResult;
  // this marks an item in IPFS as "forsale"
  mapping (bytes32 => bool) public forSale;
  // mapping URI (with substituted {id}) to bonus stat multiplier
  mapping (uint256 => uint256) public bonusStat;


  constructor(bytes32[] memory fruitForSale) ERC1155("https://gateway.ipfs.io/ipns/k51qzi5uqu5dhhsypzzx2rmkhmj5kl84r3cvv4vckw73wmpgn47m2wkgny2o99/{id}.json")
    VRFConsumerBase(_vrfCoordinator, _link) {

    for(uint256 i=0; i<fruitForSale.length; i++){
      forSale[assetsForSale[i]] = true;
    }
    keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    fee = 0.1 * 10 ** 18; // 0.1 LINK
  }

  // ERC1155MetadataURI
  function uri(uint256 id) external view returns (string memory) {

    // @TODO: returns the URI link with {id} substituted 
    return id;
  }

  // @dev: Chainlink VRF functions
  function getRandomNumber(uint256 usersFruitySeeds) public returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee, userProvidedSeed);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override returns (uint256) {
    randomResult = randomness;
  }

  // @dev: mint function with randomization
  function mintNFT(address account, uint256 id, uint256 amount, bytes memory data) public returns (uint256) {
    // require(hasRole("PREMINT_ROLE", msg.sender), "not msg sender"); // we want this function to only be called by our wallet, not msg sender. Need to update this.
    require(forSale[uriHash],"Not for sale");
    forSale[uriHash]=false;    


    _mint(account, id, amount, data);
    
    return id;
  }
}