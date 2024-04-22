// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TipBot is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable {
    // address public owner;

    mapping(address => uint256) public depositedBalances;

    address topUpAddress;
    uint256 fee; // Fee percentage (e.g., 5 for 5%)
    uint256 feeAmount; // Fee amount


    mapping(address => uint256) public feeERC20Amount; // Fee amount
    
    mapping(address => mapping(address => uint256)) public depositedBalancesERC20;

    event Deposit(address indexed depositor, uint256 value);
    event DepositERC20(address indexed tokenERC20, address indexed depositor, uint256 value);
    event Withdraw(address indexed owner, uint256 value);
    event WithdrawERC20(address indexed tokenERC20, address indexed depositor, uint256 value);
    event Tip(address indexed from, address indexed to, uint256 amount, uint256 feeAmount);
    event TipERC20(address indexed tokenERC20,address indexed from, address indexed to, uint256 amount, uint256 feeAmount);
    event WithdrawFee(address indexed owner, uint256 feeAmount);
    event WithdrawFeeERC20(address indexed tokenERC20, address indexed owner, uint256 feeAmount);

    function initialize() initializer public {
        __ERC20_init("BTT TIP", "TIP");
        __ERC20Burnable_init();
        __Ownable_init();
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit value must be greater than zero");

        depositedBalances[msg.sender] += msg.value;
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function depositTopUp() external payable {
        require(msg.value > 0, "Deposit value must be greater than zero");
        depositedBalances[topUpAddress] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function depositERC20(address tokenAddress, uint256 amount) public {
        require(amount > 0, "Deposit value must be greater than zero");

        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        depositedBalancesERC20[msg.sender][tokenAddress] += amount;
        emit DepositERC20(tokenAddress, msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0 && amount <= depositedBalances[msg.sender], "Invalid withdraw amount");
        depositedBalances[msg.sender] -= amount;

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(amount); 
        emit Withdraw(msg.sender, amount);
    }

    function withdrawERC20(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Deposit value must be greater than zero");

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, amount), "Token transfer failed");

        depositedBalancesERC20[msg.sender][tokenAddress] -= amount;
        emit WithdrawERC20(tokenAddress, msg.sender, amount);
    }

    function withdrawFee(address _to) external onlyOwner {
        require(feeAmount > 0, "No fee balance to withdraw");

        payable(_to).transfer(feeAmount); 
        emit WithdrawFee(_to, feeAmount);
    }

    function withdrawFeeERC20(address tokenAddress, address _to) external onlyOwner {
        require(feeERC20Amount[tokenAddress] > 0, "No fee balance to withdraw");

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(_to, feeERC20Amount[tokenAddress]), "Token transfer failed");
        emit WithdrawFee(_to, feeAmount);
    }

    function tip(address to, uint256 amount) public {
        require(to != address(0), "Invalid tip address");
        require(amount > 0 && amount <= depositedBalances[msg.sender], "Invalid tip amount");

        uint256 feePaid = (amount * fee) / 100;
        uint256 netAmount = amount - feePaid;

        depositedBalances[msg.sender] -= amount;
        feeAmount += feePaid; // Accumulate fee amount

        _burn(msg.sender, amount);

        payable(to).transfer(netAmount); // Transfer net amount to the recipient

        emit Tip(msg.sender, to, netAmount, feeAmount);
    }

    // Create a function to tip multiple addresses at once
    function tipMultiple(address[] memory to, uint256[] memory amount) public {
        require(to.length == amount.length, "Invalid input length");

        for (uint256 i = 0; i < to.length; i++) {
            tip(to[i], amount[i]);
        }
    }

    function tipERC20(address tokenAddress, address to, uint256 amount) public {
        require(to != address(0), "Invalid tip address");
        require(amount > 0 && amount <= depositedBalancesERC20[msg.sender][tokenAddress], "Invalid tip amount");

        uint256 feePaid = (amount * fee) / 100;
        uint256 netAmount = amount - feePaid;

        depositedBalancesERC20[msg.sender][tokenAddress] -= amount;
        feeERC20Amount[tokenAddress] += feePaid; // Accumulate fee amount

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(to, netAmount), "Token transfer failed");
        emit TipERC20(tokenAddress, msg.sender, to, netAmount, feeAmount);
    }

    // Create a function to tip multiple ERC20 tokens addresses at once
    function tipERC20Multiple(address tokenAddress, address[] memory to, uint256[] memory amount) public {
        require(to.length == amount.length, "Invalid input length");

        for (uint256 i = 0; i < to.length; i++) {
            tipERC20(tokenAddress, to[i], amount[i]);
        }
    }

    // Create a function that allows depositing ERC20 tokens and tipping them
    function depositAndTipERC20(address tokenAddress, uint256 amount, address to, uint256 tipAmount) external {
        depositERC20(tokenAddress, amount);
        tipERC20(tokenAddress, to, tipAmount);
    }

    // Create a function that deposits ERC20 tokens and tips them to multiple addresses
    function depositAndTipERC20Multiple(address tokenAddress, uint256 amount, address[] memory to, uint256[] memory tipAmount) external {
        depositERC20(tokenAddress, amount);
        tipERC20Multiple(tokenAddress, to, tipAmount);
    }

    function tipTopUp(address to, uint256 amount) external onlyOwner{
        require(to != address(0), "Invalid tip address");
        require(amount > 0 && amount <= depositedBalances[topUpAddress], "Invalid tip amount");

        uint256 feePaid = (amount * fee) / 100;
        uint256 netAmount = amount - feePaid;

        depositedBalances[topUpAddress] -= amount;
        feeAmount += feePaid; // Accumulate fee amount

        _burn(topUpAddress, amount);

        payable(to).transfer(netAmount); // Transfer net amount to the recipient

        emit Tip(topUpAddress, to, netAmount, feeAmount);
    }

    // TOP Up is a function to bring the balance off chain to the bot
    function topUp(uint256 amount) external {
        require(amount > 0 && amount <= depositedBalances[msg.sender], "Invalid withdrawal amount");
        depositedBalances[msg.sender] -= amount;
        depositedBalances[topUpAddress] += amount;

        _transfer(msg.sender, topUpAddress, amount);
    }

    // TOP Up is a function to bring the balance off chain to the bot
    function topUpERC20(address tokenAddress, uint256 amount) external {
        require(amount > 0 && amount <= depositedBalancesERC20[msg.sender][tokenAddress], "Invalid withdrawal amount");
        depositedBalancesERC20[msg.sender][tokenAddress] -= amount;
        depositedBalancesERC20[topUpAddress][tokenAddress] += amount;
    }

    // TOP Up is a function to bring the balance off chain to the bot
    function topUpOwner(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid input address");
        require(amount > 0 && amount <= depositedBalances[to], "Invalid withdrawal amount");
        depositedBalances[to] -= amount;
        depositedBalances[topUpAddress] += amount;

        _transfer(to, topUpAddress, amount);
    }

    // TopUp Address is the address which holds all offline balances
    function setTopUpAddress(address _topUpAddress) external onlyOwner {
        topUpAddress = _topUpAddress;
    }

    // We apply fee for withdrawal only 
    function setFee(uint256 _fee) external onlyOwner {
        require(_fee <= 100, "Fee percentage cannot exceed 100%");
        fee = _fee;
    }

    function getDepositedBalance(address depositor) external view returns (uint256) {
        return depositedBalances[depositor];
    }

    function getDepositedBalanceERC20(address tokenAddress, address depositor) external view returns (uint256) {
        return depositedBalancesERC20[depositor][tokenAddress];
    }

    function getFeeProcent() external view returns (uint256) {
        return fee;
    }

    function getFeeBalance() external view returns (uint256) {
        return feeAmount;
    }

    function getFeeBalanceERC20(address tokenAddress) external view returns (uint256) {
        return feeERC20Amount[tokenAddress];
    }

    function getTopUpAddress() external view returns (address) {
        return topUpAddress;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
