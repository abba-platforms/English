// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ENGLISH Coin
 * @dev A meme coin deployed on Binance Smart Chain with batch minting, burn, and meme-sharing features.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner_, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 amount);
    event Meme(address indexed sender, uint256 amount, string meme);
}

contract ENGLISH is IERC20 {
    string public constant name = "English Coin";
    string public constant symbol = "ENGLISH";
    uint8 public constant decimals = 18;

    uint256 private _totalSupply;

    uint256 public constant MAX_SUPPLY = 100_000_000_000 * 10**18; // 100B tokens
    uint256 public constant MINT_CHUNK = 10_000_000_000 * 10**18; // 10B tokens per batch

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public owner;

    constructor() {
        owner = msg.sender;
        _totalSupply = 0;
        _balances[msg.sender] = 0;
        emit Transfer(address(0), msg.sender, 0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    // ------------------------
    // Mint in batches of 10B tokens
    // ------------------------
    function mintBatch() external onlyOwner {
        require(_totalSupply < MAX_SUPPLY, "Max supply reached");

        uint256 amountToMint = MINT_CHUNK;
        if (_totalSupply + MINT_CHUNK > MAX_SUPPLY) {
            amountToMint = MAX_SUPPLY - _totalSupply; // last batch
        }

        _balances[msg.sender] += amountToMint;
        _totalSupply += amountToMint;

        emit Transfer(address(0), msg.sender, amountToMint);
    }

    // ------------------------
    // ERC20 functions
    // ------------------------
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(from, msg.sender, currentAllowance - amount);
        _transfer(from, to, amount);
        return true;
    }

    // ------------------------
    // Burn and Meme Functions
    // ------------------------
    function burn(uint256 amount) public returns (bool) {
        require(_balances[msg.sender] >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[msg.sender] -= amount;
            _totalSupply -= amount;
        }
        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
        return true;
    }

    function burnForMeme(uint256 amount, string calldata meme) external returns (bool) {
        require(bytes(meme).length <= 256, "Meme string too long");
        burn(amount);
        emit Meme(msg.sender, amount, meme);
        return true;
    }

    // ------------------------
    // Allowance Management
    // ------------------------
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    // ------------------------
    // Internal Helpers
    // ------------------------
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    // ------------------------
    // Ownership Controls
    // ------------------------
    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}
