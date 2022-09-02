// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./nf-token.sol";
import "./erc721-enumerable.sol";
import "./erc721-metadata.sol";

/**
 * @dev Optional enumeration implementation for ERC-721 non-fungible token standard.
 */
contract NFTokenMetaEnumerable is NFToken, ERC721Enumerable, ERC721Metadata {
  /**
   * @dev A descriptive name for a collection of NFTs.
   */
  string internal nftName;

  /**
   * @dev An abbreviated name for NFTokens.
   */
  string internal nftSymbol;

  uint256 internal last_token_id;

  /**
   * @dev Mapping from NFT ID to metadata uri.
   */
  mapping(uint256 => string) internal idToUri;
  /**
   * @dev List of revert message codes. Implementing dApp should handle showing the correct message.
   * Based on 0xcert framework error codes.
   */
  string constant INVALID_INDEX = "005007";

  /**
   * @dev Array of all NFT IDs.
   */
  uint256[] internal tokens;

  /**
   * @dev Mapping from token ID to its index in global tokens array.
   */
  mapping(uint256 => uint256) internal idToIndex;

  /**
   * @dev Mapping from owner to list of owned NFT IDs.
   */
  mapping(address => uint256[]) internal ownerToIds;

  /**
   * @dev Mapping from NFT ID to its index in the owner tokens list.
   */
  mapping(uint256 => uint256) internal idToOwnerIndex;

  /**
   * @dev Contract constructor.
   */
  constructor() {
    supportedInterfaces[0x780e9d63] = true; // ERC721Enumerable
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
    nftName = "SPOON NFT";
    nftSymbol = "SPOON";
    last_token_id = 0;
  }

  /**
   * @dev Returns a descriptive name for a collection of NFTokens.
   * @return _name Representing name.
   */
  function name() external view override returns (string memory _name) {
    _name = nftName;
  }

  /**
   * @dev Returns an abbreviated name for NFTokens.
   * @return _symbol Representing symbol.
   */
  function symbol() external view override returns (string memory _symbol) {
    _symbol = nftSymbol;
  }

  /**
   * @dev A distinct URI (RFC 3986) for a given NFT.
   * @param _tokenId Id for which we want uri.
   * @return URI of _tokenId.
   */
  function tokenURI(uint256 _tokenId)
    external
    view
    override
    validNFToken(_tokenId)
    returns (string memory)
  {
    return _tokenURI(_tokenId);
  }

  /**
   * @notice This is an internal function that can be overriden if you want to implement a different
   * way to generate token URI.
   * @param _tokenId Id for which we want uri.
   * @return URI of _tokenId.
   */
  function _tokenURI(uint256 _tokenId) internal view virtual returns (string memory) {
    return idToUri[_tokenId];
  }

  /**
   * @notice This is an internal function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @dev Set a distinct URI (RFC 3986) for a given NFT ID.
   * @param _tokenId Id for which we want URI.
   * @param _uri String representing RFC 3986 URI.
   */
  function _setTokenUri(uint256 _tokenId, string memory _uri) internal validNFToken(_tokenId) {
    idToUri[_tokenId] = _uri;
  }

  /**
   * @dev Returns the count of all existing NFTokens.
   * @return Total supply of NFTs.
   */
  function totalSupply() external view override returns (uint256) {
    return tokens.length;
  }

  /**
   * @dev Returns NFT ID by its index.
   * @param _index A counter less than `totalSupply()`.
   * @return Token id.
   */
  function tokenByIndex(uint256 _index) external view override returns (uint256) {
    require(_index < tokens.length, INVALID_INDEX);
    return tokens[_index];
  }

  /**
   * @dev returns the n-th NFT ID from a list of owner's tokens.
   * @param _owner Token owner's address.
   * @param _index Index number representing n-th token in owner's list of tokens.
   * @return Token id.
   */
  function tokenOfOwnerByIndex(address _owner, uint256 _index)
    external
    view
    override
    returns (uint256)
  {
    require(_index < ownerToIds[_owner].length, INVALID_INDEX);
    return ownerToIds[_owner][_index];
  }

  function mint(
    address _to,
    // uint256 _tokenId,
    string calldata _uri
  ) public {
    last_token_id++;
    _mint(_to, last_token_id);
    _setTokenUri(last_token_id, _uri);
  }

  /**
   * @notice This is an internal function which should be called from user-implemented external
   * mint function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @dev Mints a new NFT.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   */
  function _mint(address _to, uint256 _tokenId) internal virtual override {
    super._mint(_to, _tokenId);
    tokens.push(_tokenId);
    idToIndex[_tokenId] = tokens.length - 1;
  }

  /**
   * @notice This is an internal function which should be called from user-implemented external
   * burn function. Its purpose is to show and properly initialize data structures when using this
   * implementation. Also, note that this burn implementation allows the minter to re-mint a burned
   * NFT.
   * @dev Burns a NFT.
   * @param _tokenId ID of the NFT to be burned.
   */
  function _burn(uint256 _tokenId) internal virtual override {
    super._burn(_tokenId);
    delete idToUri[_tokenId];

    uint256 tokenIndex = idToIndex[_tokenId];
    uint256 lastTokenIndex = tokens.length - 1;
    uint256 lastToken = tokens[lastTokenIndex];

    tokens[tokenIndex] = lastToken;

    tokens.pop();
    // This wastes gas if you are burning the last token but saves a little gas if you are not.
    idToIndex[lastToken] = tokenIndex;
    idToIndex[_tokenId] = 0;
  }

  /**
   * @notice Use and override this function with caution. Wrong usage can have serious consequences.
   * @dev Removes a NFT from an address.
   * @param _from Address from wich we want to remove the NFT.
   * @param _tokenId Which NFT we want to remove.
   */
  function _removeNFToken(address _from, uint256 _tokenId) internal virtual override {
    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    delete idToOwner[_tokenId];

    uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
    uint256 lastTokenIndex = ownerToIds[_from].length - 1;

    if (lastTokenIndex != tokenToRemoveIndex) {
      uint256 lastToken = ownerToIds[_from][lastTokenIndex];
      ownerToIds[_from][tokenToRemoveIndex] = lastToken;
      idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    }

    ownerToIds[_from].pop();
  }

  /**
   * @notice Use and override this function with caution. Wrong usage can have serious consequences.
   * @dev Assigns a new NFT to an address.
   * @param _to Address to wich we want to add the NFT.
   * @param _tokenId Which NFT we want to add.
   */
  function _addNFToken(address _to, uint256 _tokenId) internal virtual override {
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
    idToOwner[_tokenId] = _to;

    ownerToIds[_to].push(_tokenId);
    idToOwnerIndex[_tokenId] = ownerToIds[_to].length - 1;
  }

  /**
   * @dev Helper function that gets NFT count of owner. This is needed for overriding in enumerable
   * extension to remove double storage(gas optimization) of owner NFT count.
   * @param _owner Address for whom to query the count.
   * @return Number of _owner NFTs.
   */
  function _getOwnerNFTCount(address _owner) internal view virtual override returns (uint256) {
    return ownerToIds[_owner].length;
  }
}
