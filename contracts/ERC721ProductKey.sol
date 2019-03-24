pragma solidity ^0.5.5;

import "./interfaces/IERC721Metadata.sol";
import "./ReentrancyGuard.sol";
import "./ERC721Enumerable.sol";
import "./ProductInventory.sol";
import "./libraries/SafeMath.sol";
import "./libraries/Strings.sol";
import "./libraries/Address.sol";
contract ERC721ProductKey is ERC721Enumerable, ReentrancyGuard, IERC721ProductKey, ProductInventory {
    using SafeMath for uint256;
    using Address for address;

    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    // Base metadata URI symbol
    string private _baseMetadataURI;
    // Withdrawal wallet
    address payable private _withdrawalWallet;

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

    struct ProductKey {
        uint256 productId;
        uint256 attributes;
        uint256 issuedTime;
        uint256 expirationTime;
    }
    
    // Map from keyid to ProductKey
    mapping (uint256 => ProductKey) public productKeys;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    /*
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
     */

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol, string memory baseURI, address payable withdrawalWallet) public {
        _name = name;
        _symbol = symbol;
        _baseMetadataURI = baseURI;
        _withdrawalWallet = withdrawalWallet;
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @notice Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the address where funds are collected.
     */
    function withdrawalWallet() public view returns (address payable) {
        return _withdrawalWallet;
    }

    /**
     * @notice Sets a Base URI to be used for token URI
     * @param baseURI string of the base uri to set
     */
    function setTokenMetadataBaseURI(string calldata baseURI) external onlyMinter {
        _baseMetadataURI = baseURI;
    }

    /**
     * @notice Returns a URI for a given ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return Strings.strConcat(
            _baseMetadataURI,
            Strings.uint2str(tokenId));
    }
    
    /**
     * @notice activates access key
     * Throws if not approved or owner or key already active
     * @param _keyId uint256 ID of the key to activate
     */
    function _activate(uint256 _keyId) internal {
        require(_isApprovedOrOwner(msg.sender, _keyId));
        require(!isKeyActive(_keyId));
        uint256 productId = productKeys[_keyId].productId;
        //set expiration time which activates the productkey
        productKeys[_keyId].expirationTime = now.add(products[productId].interval);
        //emit key activated event
        emit KeyActivated(
            ownerOf(_keyId),
            msg.sender,
            _keyId,
            productId,
            productKeys[_keyId].attributes,
            productKeys[_keyId].issuedTime,
            productKeys[_keyId].expirationTime
        );
    }

    function _createKey(
        uint256 _productId,
        address _beneficiary
    )
    internal
    returns (uint)
    {
        ProductKey memory _productKey = ProductKey({
            productId: _productId,
            attributes: 0,
            issuedTime: now, 
            expirationTime: 0
        });

        uint256 newKeyId = totalSupply();
            
        productKeys[newKeyId] = _productKey;
        emit KeyIssued(
            _beneficiary,
            msg.sender,
            newKeyId,
            _productKey.productId,
            _productKey.attributes,
            _productKey.issuedTime,
            _productKey.expirationTime);
        _mint(_beneficiary, newKeyId);
        return newKeyId;
    }

    function _setKeyAttributes(uint256 _keyId, uint256 _attributes) internal
    {
        productKeys[_keyId].attributes = _attributes;
    }

    function _purchase(
        uint256 _productId,
        address _beneficiary)
    internal returns (uint)
    {
        _purchaseProduct(_productId);
        return _createKey(
            _productId,
            _beneficiary
        );
    }

    /** only minter **/

    function withdrawBalance() external onlyMinter {
        _withdrawalWallet.transfer(address(this).balance);
    }

    function minterOnlyPurchase(
        uint256 _productId,
        address _beneficiary
    )
    external
    onlyMinter
    returns (uint256)
    {
        return _purchase(
            _productId,
            _beneficiary
        );
    }

    function setKeyAttributes(
        uint256 _keyId,
        uint256 _attributes
    )
    external
    onlyMinter
    {
        return _setKeyAttributes(
            _keyId,
            _attributes
        );
    }

    /** anyone **/

    /**
    * @notice Get if productkey is active
    * @param _keyId the id of key
    */
    function isKeyActive(uint256 _keyId) public view returns (bool) {
        return productKeys[_keyId].expirationTime > now || products[productKeys[_keyId].productId].interval == 0;
    }

    /**
    * @notice Get a ProductKey's info
    * @param _keyId key id
    */
    function keyInfo(uint256 _keyId)
    public view returns (uint256, uint256, uint256, uint256)
    {
        return (productKeys[_keyId].productId,
            productKeys[_keyId].attributes,
            productKeys[_keyId].issuedTime,
            productKeys[_keyId].expirationTime
        );
    }

    /**
    * @notice purchase a product
    * @param _productId - product id to purchase
    * @param _beneficiary - the token receiving address
    */
    function purchase(
        uint256 _productId,
        address _beneficiary
    )
    external
    payable
    returns (uint256)
    {
        require(_productId != 0);
        require(_beneficiary != address(0));
        // No excess
        require(msg.value == priceOf(_productId));
        require(!isMinterOnly(_productId));
        return _purchase(
            _productId,
            _beneficiary
        );
    }

    /**
    * @notice activates token
    */
    function activate(
        uint256 _tokenId
    )
    external
    payable
    {
        require(ownerOf(_tokenId) != address(0));
        // no excess
        require(msg.value == priceOfActivation(_tokenId));
        _activate(_tokenId);

    }
}