// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TipBot is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable {
    // address public owner;

    mapping(address => uint256) public depositedBalances;
    address topUpAddress;
    uint256 fee; // Fee percentage (e.g., 5 for 5%)
    uint256 feeAmount; // Fee amount

    event Deposit(address indexed depositor, uint256 value);
    event Withdraw(address indexed owner, uint256 value);
    event Tip(address indexed from, address indexed to, uint256 amount, uint256 feeAmount);
    event WithdrawFee(address indexed owner, uint256 feeAmount);

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

    function withdraw(uint256 amount) external {
        require(amount > 0 && amount <= depositedBalances[msg.sender], "Invalid withdraw amount");
        depositedBalances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount); // Transfer accumulated fee to the owner
        emit Withdraw(msg.sender, amount);
    }

    function withdrawFee(address _to) external onlyOwner {
        require(feeAmount > 0, "No fee balance to withdraw");

        payable(_to).transfer(feeAmount); // Transfer accumulated fee to the owner
        emit WithdrawFee(_to, feeAmount);
    }

    function tip(address to, uint256 amount) external {
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

    function getFeeProcent() external view returns (uint256) {
        return fee;
    }

    function getFeeBalance() external view returns (uint256) {
        return feeAmount;
    }

    function getTopUpAddress() external view returns (address) {
        return topUpAddress;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
