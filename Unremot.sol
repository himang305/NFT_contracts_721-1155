
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Unremot is ERC1155 {
     
    uint _tokenIds; 
    uint _listPrice; 
    uint _mintPrice; 
    string public name;
    string public symbol;
    address private admin; 
    address private owner; 
    mapping (uint256 => string) private _tokenURI;
    mapping(address => mapping(uint256 => uint256)) allowances;

    event Mint(address _from, uint indexed tokenId, uint amount, string tokenURI);
    event ChangeOwner(address newOwner,address oldowner);
    event ChangeAdmin(address newAdmin,address oldadmin);
    event OwnershipTransfer(address from,address to, uint indexed tokenId, uint amount);
    event ApproveOwnership(address sender);
    event NFTPayment(address indexed sender, uint value);
    event ListingPrice(uint newListPrice, uint _oldListPrice);
    event MintingPrice(uint newMintPrice, uint _oldMintPrice);    
    event BurnNFT(address account,uint id,uint amount);
    event Withdrawal(uint amount);
    event Received(address sender, uint amount);
    event Fallback(address sender, uint amount);

    constructor(address admins) ERC1155("") {
            name = 'Unremot_Contract';
            symbol = 'Programming NFT';
            owner = msg.sender;
            admin = admins;
            _tokenIds = 1;
            _listPrice = 0;
            _mintPrice = 0;
    }
    modifier onlyOwner {
    require(msg.sender == owner, "Not market owner"); 
      _;
    }
    modifier onlyAdmin {
    require(msg.sender == admin, "Not market admin"); 
      _;
    }
    
    function changeOwner(address newOwner) external onlyAdmin
    {
        emit ChangeOwner(newOwner, owner);
        owner = newOwner;
    }
    function changeAdmin(address newAdmin) external onlyAdmin
    {
        emit ChangeAdmin(newAdmin, admin);
        admin = newAdmin;
    }
    function getAdmin() external onlyAdmin view returns(address)
    {
        return admin;
    }
    function getOwner() external onlyAdmin view returns(address)
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

    function mint(uint256 amount, string memory uriDetail) external payable
    {
        require(msg.value >= _mintPrice, "Insufficient funds for minting");    
        _mint(msg.sender, _tokenIds , amount, bytes('0x0'));
        _tokenURI[_tokenIds] = uriDetail; 
        setApprovalForAll(owner, true);
        allowances[msg.sender][_tokenIds] = amount;
        emit Mint(msg.sender, _tokenIds, amount, uriDetail);
        _tokenIds++ ;
    }

    function transferOwnership(uint256 tokenId, uint256 amount, address from, address to ) external onlyOwner
    {
        require(allowances[from][tokenId] > 0, "No existing approvals");  
        allowances[from][tokenId] = allowances[from][tokenId] - 1 ;       
        safeTransferFrom(from, to, tokenId, amount, bytes('0x0')); // bytes()
        emit OwnershipTransfer(from, to, tokenId, amount);
    }

    function approveOwnership(uint tokenID, uint amount) external payable
    {
        require(msg.value >= _listPrice, "Insufficient funds for listing");    
        setApprovalForAll(owner, true);
        allowances[msg.sender][tokenID] = allowances[msg.sender][tokenID] + amount;
        emit ApproveOwnership(msg.sender);
    }

    function getApproveOwnership(uint tokenID, address sender) external view returns (uint)
    {
        return(allowances[sender][tokenID]);
    }

    function buyNFT() external payable
    {
        require(msg.value > 0 , "Insufficient funds for NFT purchase");    
        emit NFTPayment(msg.sender, msg.value);
    }

    function getUri(uint256 tokenId) external onlyOwner view returns (string memory) {
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

    function balanceOfContract() external view onlyAdmin returns(uint){
        return address(this).balance;  
    }

    function withdraw() external onlyAdmin{
        payable(admin).transfer(address(this).balance);  
        emit Withdrawal(address(this).balance);
    }
}






