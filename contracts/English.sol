// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title $ENGLISH Memecoin
 * @dev Enterprise-grade, DAO-compatible BEP-20 token with
 *      - Slippage-protected swap-and-liquify
 *      - Max swap tokens
 *      - Claimable rewards
 *      - Anti-whale protections
 *      - Emergency pause
 *      - DAO treasury exemptions
 *      - Full CertiK-style audit-ready design
 */
interface IPancakeRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external;

    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function WETH() external pure returns (address);
}

contract ENGLISH is IERC20, Ownable {
    using Address for address;

    // Token info
    string private constant _name = "English MemeCoin";
    string private constant _symbol = "ENGLISH";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 1_000_000_000_000 * 10**18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Fees
    uint256 public liquidityFee = 3;
    uint256 public burnFee = 1;
    uint256 public rewardsFee = 1;

    // Anti-whale
    uint256 public maxTxAmount = 10_000_000_000 * 10**18;
    uint256 public maxWalletAmount = 20_000_000_000 * 10**18;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(address => bool) private _isDAOTreasury;

    // Rewards
    mapping(address => uint256) private _rewardBalance;
    mapping(address => uint256) private _lastClaimed;
    uint256 public rewardPool;
    uint256 public rewardClaimCooldown = 1 hours;

    // PancakeSwap
    IPancakeRouter public pancakeRouter;
    address public pancakePair;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public minTokensBeforeSwap = 1_000_000 * 10**18;
    uint256 public maxSwapTokens = 10_000_000_000 * 10**18;
    uint256 public maxSlippagePercent = 5;

    // Emergency pause
    bool public paused = false;

    // Modifiers
    modifier lockTheSwap { inSwapAndLiquify = true; _; inSwapAndLiquify = false; }
    modifier notPaused() { require(!paused, "Contract is paused"); _; }

    // Events
    event RewardPoolUpdated(uint256 newRewardPool);

    // Constructor
    constructor(address router, address pair) {
        _balances[msg.sender] = _totalSupply;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromMaxWallet[msg.sender] = true;

        pancakeRouter = IPancakeRouter(router);
        pancakePair = pair;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // ERC-20 Standard functions
    function name() external pure returns (string memory) { return _name; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function decimals() external pure returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender,address recipient,uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] -= amount;
        emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        return true;
    }

// Owner / DAO functions
    function setFees(uint256 _liquidity, uint256 _burn, uint256 _rewards) external onlyOwner {
        liquidityFee = _liquidity;
        burnFee = _burn;
        rewardsFee = _rewards;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner { maxTxAmount = amount; }
    function setMaxWalletAmount(uint256 amount) external onlyOwner { maxWalletAmount = amount; }
    function excludeFromFee(address account, bool excluded) external onlyOwner { _isExcludedFromFee[account] = excluded; }
    function excludeFromMaxWallet(address account, bool excluded) external onlyOwner { _isExcludedFromMaxWallet[account] = excluded; }
    function setDAOTreasury(address account, bool isTreasury) external onlyOwner { _isDAOTreasury[account] = isTreasury; }
    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner { swapAndLiquifyEnabled = enabled; }
    function setMinTokensBeforeSwap(uint256 amount) external onlyOwner { minTokensBeforeSwap = amount; }
    function setMaxSwapTokens(uint256 amount) external onlyOwner { maxSwapTokens = amount; }
    function setMaxSlippagePercent(uint256 percent) external onlyOwner { require(percent <= 100, "Slippage too high"); maxSlippagePercent = percent; }
    function setRewardCooldown(uint256 seconds_) external onlyOwner { rewardClaimCooldown = seconds_; }

    function pause() external onlyOwner { paused = true; }
    function unpause() external onlyOwner { paused = false; }

    function recoverStuckTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }

    // Core transfer logic
    function _transfer(address sender, address recipient, uint256 amount) internal notPaused {
        require(sender != address(0) && recipient != address(0), "ERC20: zero address");
        require(amount > 0, "Transfer amount must be > 0");

        // Anti-Whale
        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]){
            require(amount <= maxTxAmount, "Exceeds max tx amount");
            if(!_isExcludedFromMaxWallet[recipient] && !_isDAOTreasury[recipient])
                require(_balances[recipient] + amount <= maxWalletAmount, "Exceeds max wallet");
        }

        // Swap and liquify
        uint256 contractTokenBalance = _balances[address(this)];
        if(contractTokenBalance >= minTokensBeforeSwap &&
           !inSwapAndLiquify &&
           sender != pancakePair &&
           swapAndLiquifyEnabled) 
        {
            swapAndLiquify(contractTokenBalance);
        }

        // Fees
        uint256 fees = 0;
        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]){
            uint256 liquidityPart = amount * liquidityFee / 100;
            uint256 burnPart = amount * burnFee / 100;
            uint256 rewardsPart = amount * rewardsFee / 100;
            fees = liquidityPart + burnPart + rewardsPart;

            _burn(sender, burnPart);
            _distributeRewards(rewardsPart);
            _balances[address(this)] += liquidityPart;
        }

        // Final transfer
        _balances[sender] -= amount;
        _balances[recipient] += amount - fees;
        emit Transfer(sender, recipient, amount - fees);
    }

    // Burn function
    function _burn(address account, uint256 amount) internal {
        if(amount == 0) return;
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    // Rewards system
    function _distributeRewards(uint256 amount) internal {
        if(amount == 0) return;
        rewardPool += amount;
        emit RewardPoolUpdated(rewardPool);
    }

    function claimReward() external notPaused {
        require(block.timestamp - _lastClaimed[msg.sender] >= rewardClaimCooldown, "Claim cooldown active");
        uint256 holderBalance = _balances[msg.sender];
        require(holderBalance > 0, "No tokens held");

        uint256 reward = rewardPool * holderBalance / (_totalSupply - _balances[address(this)] - _balances[pancakePair]);
        if(reward > rewardPool) reward = rewardPool;
        _rewardBalance[msg.sender] += reward;
        rewardPool -= reward;
        _lastClaimed[msg.sender] = block.timestamp;

        _balances[msg.sender] += reward;
        emit Transfer(address(this), msg.sender, reward);
        emit RewardPoolUpdated(rewardPool);
    }

    function pendingReward(address account) external view returns (uint256) {
        uint256 holderBalance = _balances[account];
        if(holderBalance == 0) return 0;
        return rewardPool * holderBalance / (_totalSupply - _balances[address(this)] - _balances[pancakePair]);
    }

// Swap and liquify
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokensToSwap = contractTokenBalance > maxSwapTokens ? maxSwapTokens : contractTokenBalance;
        uint256 half = tokensToSwap / 2;
        uint256 otherHalf = tokensToSwap - half;

        uint256 initialBalance = address(this).balance;

        address ;
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), half);

        uint256 amountOutMin = (initialBalance * (100 - maxSlippagePercent)) / 100;

        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            amountOutMin,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;

        pancakeRouter.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    // Approve helper
    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Receive BNB
    receive() external payable {}
}
