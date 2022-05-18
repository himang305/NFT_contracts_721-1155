// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFTMarketPlace is ERC1155 {
     
    uint _tokenIds; 
    uint _listPrice; 
    uint _mintPrice; 
    uint _changePrice;
    string public name;
    string public symbol;
    address private owner; 
    mapping (uint256 => string) public _tokenURI;
    mapping (address => mapping(uint256 => uint256)) public _price;

    event Mint(address _from, uint indexed tokenId, uint amount, string tokenURI, uint price);
    event ChangeOwner(address newOwner,address oldowner);
    event OwnershipTransfer(address from,address to, uint indexed tokenId, uint amount, uint price);
    event PriceChangeEvent ( uint tokenId, uint old_price, uint price);
    event listSetPrice (address from, uint tokenId,uint price);
    event ListingPrice(uint newListPrice, uint _oldListPrice);
    event MintingPrice(uint newMintPrice, uint _oldMintPrice);   
    event ChangePrice(uint newPrice, uint _oldPrice);    
    event BurnNFT(address account,uint id,uint amount);
    event Withdrawal(uint amount);
    event Received(address sender, uint amount);
    event Fallback(address sender, uint amount);

    constructor() ERC1155("") {
            name = 'NFT_Contract';
            symbol = 'ERC_1155';
            owner = msg.sender;
            _tokenIds = 1;
            _listPrice = 0;
            _mintPrice = 0;
            _changePrice = 0;
    }
    modifier onlyOwner {
    require(msg.sender == owner, "Not market owner"); 
      _;
    }
    
    function mintAndList(uint256 price, uint256 amount, string memory uriDetail) external payable
    {
        require(msg.value >= _mintPrice, "Insufficient funds for minting");    
        _mint(msg.sender, _tokenIds , amount, bytes('0x0'));
        _tokenURI[_tokenIds] = uriDetail; 
        _price[msg.sender][_tokenIds] = price;
        emit Mint( msg.sender, _tokenIds, amount, uriDetail, price);
        _tokenIds++ ;
    }

    function transferOwnershipAndList(uint256 tokenId, address from, uint price ) external payable
    {
        require(_price[from][tokenId] > 0, "NFT Not for Sale");    
        require(msg.value >= _price[from][tokenId], "Insufficient funds for transfer");    
        _safeTransferFrom(from, msg.sender, tokenId ,1 , bytes('0x0'));
        _price[msg.sender][tokenId] = price;
        payable(from).transfer(_price[from][tokenId]);
        emit OwnershipTransfer( from, msg.sender, tokenId, 1, msg.value);
    }

    function changePrice(uint tokenId, uint price) external payable
    {
        require(msg.value >= _changePrice, "Insufficient funds for minting");    
        require(balanceOf(msg.sender,tokenId) > 0, "Buy NFT before changing price");
        emit PriceChangeEvent ( tokenId, _price[msg.sender][tokenId], price);
        _price[msg.sender][tokenId] = price;
    }

    function listAndSetPrice(uint tokenId, uint price ) external payable
    {
        require(msg.value >= _listPrice, "Insufficient funds for minting");    
        require(balanceOf(msg.sender,tokenId) > 0, "Buy NFT before listing");
        _price[msg.sender][tokenId] = price;
        emit listSetPrice (msg.sender, tokenId, price);
    }

    function changeOwner(address newOwner) external onlyOwner
    {
        emit ChangeOwner(newOwner, owner);
        owner = newOwner;
    }

    function getOwner() external onlyOwner view returns(address)
    {
        return owner;
    }

    function setListingPrice(uint256 listPrice) external onlyOwner
    {
        emit ListingPrice(listPrice, _listPrice);
        _listPrice = listPrice;
    }
    function getListingPrice() external onlyOwner view returns(uint256)
    {
        return _listPrice ;
    }
    function setMintingPrice(uint256 mintPrice) external onlyOwner
    {
        emit MintingPrice(mintPrice, _mintPrice);
        _mintPrice = mintPrice;
    }
    function getMintingPrice() external onlyOwner view returns(uint256)
    {
        return _mintPrice ;
    }
    function setChangePrice(uint256 newChangePrice) external onlyOwner
    {
        emit ChangePrice(newChangePrice, _changePrice);
        _changePrice = newChangePrice;
    }
    function getChangingPrice() external onlyOwner view returns(uint256)
    {
        return _changePrice ;
    }

    function getUri(uint256 tokenId) external view returns (string memory) {
        return(_tokenURI[tokenId]);
    }

    function burnNFT(address account, uint256 id, uint256 amount) external onlyOwner
    {
        _burn(account, id, amount);
        emit BurnNFT(account, id, amount);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Fallback(msg.sender, msg.value);
    }

    function balanceOfContract() external view onlyOwner returns(uint){
        return address(this).balance;  
    }

    function withdraw() external onlyOwner{
        payable(owner).transfer(address(this).balance);  
        emit Withdrawal(address(this).balance);
    }

}
