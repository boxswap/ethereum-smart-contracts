pragma solidity ^0.5.5;

import "./MinterRole.sol";

contract ProductInventory is MinterRole {
    using SafeMath for uint256;
    using Address for address;
    
    event ProductCreated(
        uint256 id,
        uint256 price,
        uint256 activationPrice,
        uint256 available,
        uint256 supply,
        uint256 interval,
        bool minterOnly
    );
    event ProductAvailabilityChanged(uint256 productId, uint256 available);
    event ProductPriceChanged(uint256 productId, uint256 price);

    // All product ids in existence
    uint256[] public allProductIds;

    // Map from product id to Product
    mapping (uint256 => Product) public products;

    struct Product {
        uint256 id;
        uint256 price;
        uint256 activationPrice;
        uint256 available;
        uint256 supply;
        uint256 sold;
        uint256 interval;
        bool minterOnly;
    }

    function _productExists(uint256 _productId) internal view returns (bool) {
        return products[_productId].id != 0;
    }

    function _createProduct(
        uint256 _productId,
        uint256 _price,
        uint256 _activationPrice,
        uint256 _initialAvailable,
        uint256 _supply,
        uint256 _interval,
        bool _minterOnly
    )
    internal
    {
        require(_productId != 0);
        require(!_productExists(_productId));
        require(_initialAvailable <= _supply);

        Product memory _product = Product({
            id: _productId,
            price: _price,
            activationPrice: _activationPrice,
            available: _initialAvailable,
            supply: _supply,
            sold: 0,
            interval: _interval,
            minterOnly: _minterOnly
        });

        products[_productId] = _product;
        allProductIds.push(_productId);

        emit ProductCreated(
            _product.id,
            _product.price,
            _product.activationPrice,
            _product.available,
            _product.supply,
            _product.interval,
            _product.minterOnly
        );
    }

    function _incrementAvailability(
        uint256 _productId,
        uint256 _increment)
        internal
    {
        require(_productExists(_productId));
        uint256 newAvailabilityLevel = products[_productId].available.add(_increment);
        //if supply isn't 0 (unlimited), we check if incrementing puts above supply
        if(products[_productId].supply != 0) {
            require(products[_productId].sold.add(newAvailabilityLevel) <= products[_productId].supply);
        }
        products[_productId].available = newAvailabilityLevel;
    }

    function _setAvailability(uint256 _productId, uint256 _availability) internal
    {
        require(_productExists(_productId));
        require(_availability >= 0);
        products[_productId].available = _availability;
    }

    function _setPrice(uint256 _productId, uint256 _price) internal
    {
        require(_productExists(_productId));
        products[_productId].price = _price;
    }

    function _purchaseProduct(uint256 _productId) internal {
        require(_productExists(_productId));
        require(products[_productId].available > 0);
        require(products[_productId].available.sub(1) >= 0);
        products[_productId].available = products[_productId].available.sub(1);
        products[_productId].sold = products[_productId].sold.add(1);
    }

    /*** public onlyMinter ***/

    /**
    * @notice Creates a Product
    * @param _productId - product id to use (immutable)
    * @param _price - price of product
    * @param _activationPrice - price of activation
    * @param _initialAvailable - the initial amount available for sale
    * @param _supply - total supply - `0` means unlimited (immutable)
    * @param _interval - interval - period of time, in seconds, users can subscribe 
    * for. If set to 0, it's not a subscription product (immutable)
    * @param _minterOnly - if true, purchase is only available to minter
    */
    function createProduct(
        uint256 _productId,
        uint256 _price,
        uint256 _activationPrice,
        uint256 _initialAvailable,
        uint256 _supply,
        uint256 _interval,
        bool _minterOnly
    )
    external
    onlyMinter
    {
        _createProduct(
            _productId,
            _price,
            _activationPrice,
            _initialAvailable,
            _supply,
            _interval,
            _minterOnly);
    }

    /**
    * @notice incrementAvailability - increments the 
    * @param _productId - product id
    * @param _increment - amount to increment
    */
    function incrementAvailability(
        uint256 _productId,
        uint256 _increment)
    external
    onlyMinter
    {
        _incrementAvailability(_productId, _increment);
        emit ProductAvailabilityChanged(_productId, products[_productId].available);
    }

    /**
    * @notice Increments the inventory of a product
    * @param _productId - the product id
    * @param _amount - the amount to set
    */
    function setAvailability(
        uint256 _productId,
        uint256 _amount)
    external
    onlyMinter
    {
        _setAvailability(_productId, _amount);
        emit ProductAvailabilityChanged(_productId, products[_productId].available);
    }

    /**
    * @notice Sets the price of a product
    * @param _productId - the product id
    * @param _price - the product price
    */
    function setPrice(uint256 _productId, uint256 _price)
    external
    onlyMinter
    {
        _setPrice(_productId, _price);
        emit ProductPriceChanged(_productId, _price);
    }

    /*** public onlyMinter ***/

    /**
    * @notice Total amount sold of a product
    * @param _productId - the product id
    */
    function totalSold(uint256 _productId) public view returns (uint256) {
        return products[_productId].sold;
    }

    /**
    * @notice Price of a product
    * @param _productId - the product id
    */
    function isMinterOnly(uint256 _productId) public view returns (bool) {
        return products[_productId].minterOnly;
    }

    /**
    * @notice Price of a product
    * @param _productId - the product id
    */
    function priceOf(uint256 _productId) public view returns (uint256) {
        return products[_productId].price;
    }

    /**
    * @notice Price of activation of a product
    * @param _productId - the product id
    */
    function priceOfActivation(uint256 _productId) public view returns (uint256) {
        return products[_productId].activationPrice;
    }

    /**
    * @notice Product info for a product
    * @param _productId - the product id
    */
    function productInfo(uint256 _productId)
    public
    view
    returns (uint256, uint256, uint256, uint256, uint256, bool)
    {
        return (
            products[_productId].price,
            products[_productId].activationPrice,
            products[_productId].available,
            products[_productId].supply,
            products[_productId].interval,
            products[_productId].minterOnly
        );
    }

  /**
  * @notice Get product ids
  */
    function getAllProductIds() public view returns (uint256[] memory) {
        return allProductIds;
    }
}