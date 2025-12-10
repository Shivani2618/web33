// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MetamintStudio {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) public {
        require(to != address(0), "Invalid address");
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function burn(uint256 value) public {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function transferWithFee(address to, uint256 value, uint256 fee) public returns (bool) {
        require(balanceOf[msg.sender] >= value + fee, "Insufficient balance");
        balanceOf[msg.sender] -= (value + fee);
        balanceOf[to] += value;
        balanceOf[address(this)] += fee;
        emit Transfer(msg.sender, to, value);
        emit Transfer(msg.sender, address(this), fee);
        return true;
    }

    function getBalance(address account) public view returns (uint256) {
        return balanceOf[account];
    }

    function getAllowance(address owner, address spender) public view returns (uint256) {
        return allowance[owner][spender];
    }

    function getDecimals() public view returns (uint8) {
        return decimals;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function getSymbol() public view returns (string memory) {
        return symbol;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function transferToContract(address to, uint256 value) public returns (bool) {
        require(isContract(to), "Recipient is not a contract");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approveAndCall(address spender, uint256 value, bytes memory data) public returns (bool) {
        require(approve(spender, value), "Approval failed");
        (bool success, ) = spender.call(data);
        require(success, "Call failed");
        return true;
    }

    function recoverTokens(address tokenAddress, address to, uint256 value) public {
        require(tokenAddress != address(this), "Cannot recover own tokens");
        IERC20(tokenAddress).transfer(to, value);
    }

    function emergencyWithdraw(address payable to, uint256 value) public {
        require(address(this).balance >= value, "Insufficient contract balance");
        to.transfer(value);
    }

    function setDecimals(uint8 newDecimals) public {
        decimals = newDecimals;
    }

    function setName(string memory newName) public {
        name = newName;
    }

    function setSymbol(string memory newSymbol) public {
        symbol = newSymbol;
    }

    function withdrawFees(address to, uint256 value) public {
        require(balanceOf[address(this)] >= value, "Insufficient fee balance");
        balanceOf[address(this)] -= value;
        balanceOf[to] += value;
        emit Transfer(address(this), to, value);
    }

    receive() external payable {}

    fallback() external payable {}
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}
