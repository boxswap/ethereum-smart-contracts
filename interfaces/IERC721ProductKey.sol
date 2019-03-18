pragma solidity ^0.5.5;

import "./interfaces/IERC721Enumerable.sol";
import "./interfaces/IERC721Metadata.sol";

contract IERC721ProductKey is IERC721Enumerable, IERC721Metadata {
    function activate(uint256 _tokenId) external;
    function purchase(uint256 _productId, address _beneficiary) external returns (uint256);
    function setKeyAttributes(uint256 _keyId, address _attributes) public;
    function keyInfo(uint256 _keyId) public;
    function isKeyActive(uint256 _keyId) public view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
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
