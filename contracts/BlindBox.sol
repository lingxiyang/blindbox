// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract  BlindBox is ERC721Enumerable,Ownable {
    using Strings for uint256;
    string [] private indexUrlList;
     mapping(uint256=>string) public _tokenURIs;
    //控制nft是否可以售卖
    bool public _isActiveSale =false;
    //是否可以打开盲盒
    bool public _revealed = false;
    
    //最大盲盒数量
     uint256 public constant MAX_SUPPLY = 1000;
    //盲盒的价格
    uint256 public mintPrice = 0.3 ether; 
    //每个地址拥有的最大盲盒书目
    uint256 public maxBalance = 1;
    //每次允许购买的最大盲盒数
    uint256 public maxMint = 1;
    string baseURI;
    string public notRevealedURI;
    string public baseExtension = ".json";
    
    constructor(string memory name_, string memory symbol_,string memory inintBaseUrl,string memory notRevealdUrl_) 
    ERC721(name_,symbol_){
    setBaseURI(inintBaseUrl);
    setNotRevealURI(notRevealdUrl_);
    
    }
    function setBaseURI(string memory _newURI) public onlyOwner {
                baseURI = _newURI;
    }
    function setNotRevealURI(string memory notRevealURI_) public onlyOwner{
                notRevealedURI = notRevealURI_;
    }
    function setMintPrice(uint256  mintprice_) public onlyOwner{
                mintPrice = mintprice_;
    }
    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }
    function flipSaleActive() public onlyOwner {
        _isActiveSale = !_isActiveSale;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

       require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if(!_revealed){
            return notRevealedURI;
        }
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        //如果用户还未开盲盒
        if(bytes(_tokenURI).length == 0){
            _tokenURI = notRevealedURI;
        }
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }
    function mintBlind(uint256  tokenQuantity) public payable{
       require(totalSupply()+ tokenQuantity <= MAX_SUPPLY);
       require(_isActiveSale, "Sale must be active to mint blind");
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");

        _mintNicMeta(tokenQuantity);

    }
     function _mintNicMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
    function openBox(uint256 tokenId) public{
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(_revealed, "Sale must be active to mint blind");
        uint256 index = tokenId % indexUrlList.length;
        _tokenURIs[tokenId] = indexUrlList[index];
    }
    function addUrl(string memory url) public onlyOwner{
        indexUrlList.push(url);
    }
    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}