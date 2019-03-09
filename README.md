# ethereum-smart-contracts

## ERC721ProductKey
### What is it? 
ERC721 Product key is a proof-of-concept non-fungible token that can represent subscription or non-subscription access keys (i.e. license keys) on Ethereum. The contract minter creates paid or free products that can be "sold" to users. Using keyInfo, the minter can distinguish from types of products and keys. Subscriptions can be required to activate before being used providing opportunity to reserve the subscription for future use. 

### Use cases:
- Paid or non-paid generic non-fungible token use cases
- Access keys that provide access to the app or features
- Subscription keys that provide access for a limited time that starts when activated
- Providing keys for multiple types of products on one smart contract

### The Interface 
```
contract IERC721ProductKey is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
    function activate(uint256 _tokenId) external;
    function purchase(uint256 _productId, address _beneficiary) external returns (uint256);
    function setKeyAttributes(uint256 _keyId, address _attributes) public;
    function keyInfo(uint256 _keyId) public;
    function isKeyActive(uint256 _keyId) public view returns (bool);
    function productInfo(uint256 _productId) public view returns (uint256, uint256, uint256, uint256, uint256);
    function getAllProductIds() public view returns (uint256[] memory);
    function priceOf(uint256 _productId) public view returns (uint256);

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
```
