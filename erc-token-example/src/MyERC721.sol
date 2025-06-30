// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyERC721 {
    string public constant name = "MyERC721";
    string public constant symbol = "M721";

    // tokenId => owner
    mapping(uint256 => address) private _owners;
    // owner => balance
    mapping(address => uint256) private _balances;
    // tokenId => approved address
    mapping(uint256 => address) private _tokenApprovals;
    // owner => operator => approved
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    uint256 private _nextId = 1;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /// @notice 토큰을 민트하여 `to`로 전송하고 tokenId 반환
    function mint(address to) external returns (uint256) {
        require(to != address(0), "mint to zero");
        uint256 tokenId = _nextId++;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        return tokenId;
    }

    /// --------------------------------
    ///            ERC721 API
    /// --------------------------------
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "nonexistent token");
        return owner;
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(to != owner, "approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "not authorized");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not owner nor approved");
        require(ownerOf(tokenId) == from, "incorrect from");
        require(to != address(0), "transfer to zero");

        // clear approvals
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        transferFrom(from, to, tokenId);
        // 호출 대상이 컨트랙트이면 onERC721Received 구현 여부를 별도로 확인하지 않음 (학습용 단순화)
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata /*data*/) external {
        safeTransferFrom(from, to, tokenId);
    }

    /// --------------------------------
    ///            내부 함수
    /// --------------------------------
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}