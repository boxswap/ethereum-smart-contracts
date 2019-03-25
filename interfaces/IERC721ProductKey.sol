pragma solidity ^0.5.5;

import "./interfaces/IERC721Enumerable.sol";
import "./interfaces/IERC721Metadata.sol";

contract IERC721ProductKey is IERC721Enumerable, IERC721Metadata {
    function activate(uint256 _tokenId) public payable;
    function purchase(uint256 _productId, address _beneficiary) public payable returns (uint256);
    function setKeyAttributes(uint256 _keyId, uint256 _attributes) public;
    function keyInfo(uint256 _keyId) external view returns (uint256, uint256, uint256, uint256);
    function isKeyActive(uint256 _keyId) public view returns (bool);
    event KeyIssued(
        address indexed owner,
        address indexed purchaser,
        uint256 keyId,
        uint256 productId,
        uint256 attributes,
        uint256 issuedTime,
        uint256 expirationTime
    );
    event KeyActivated(
        address indexed owner,
        address indexed activator,
        uint256 keyId,
        uint256 productId,
        uint256 attributes,
        uint256 issuedTime,
        uint256 expirationTime
    );
}