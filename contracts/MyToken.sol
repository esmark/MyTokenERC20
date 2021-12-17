//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./Owned.sol";


/** 
* @title MyERC20Token token contract
* @author Kamil Khadeyev
* @notice You can use this ERC20 contract for only the most basic simulation
* @dev All function calls are currently implemented without side effects
* @notice ERC Token Standard #20 Interface
* @notice https:///github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
*/
interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address to, uint256 tokens) external returns (bool);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function approve(address spender, uint256 tokens) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


/** 
* @notice ERC20 Token, with the addition of symbol, name and decimals and assisted token transfers
* @dev symbol of the token
* @dev name of the token
* @dev decimals of the token = 0
* @dev total_supply total supply
*/
contract MyToken is ERC20Interface, Owned {
    string public constant symbol = "MET";
    string public constant name = "My ERC20 Token";
    uint8 public immutable decimals = 0;
    uint256 public total_supply = 100000000;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;


    /// @notice Constructor
    constructor() {
        balances[msg.sender] = total_supply;
        emit Transfer(address(0), msg.sender, total_supply);
    }


    /// @notice Total supply
    function totalSupply() public override view returns (uint256) {
        return total_supply;
    }


    /// @notice Get the token balance for account tokenOwner
    /// @param tokenOwner is address of token owner
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }


    /// @notice Transfer the balance from token owner's account to 
    /// @param to account (address of receiver). Owner's account must have sufficient balance to transfer
    /// @param tokens - 0 value transfers are allowed
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint256 tokens) public override returns (bool) {
        require(to != address(0), "Disallow transfer to 0 address");
        require(tokens <= balances[msg.sender], "Not enough tokens on the balance");
        balances[msg.sender] = balances[msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    /** 
    * @notice Token owner can approve for 
    * @param spender to transferFrom(...) 
    * @param tokens from the token owner's account
    * @return Whether the approval was successful or not
    *
    * @notice https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    * recommends that there are no checks for the approval double-spend attack
    * as this should be implemented in user interfaces 
    */
    function approve(address spender, uint256 tokens) public override returns (bool) {
        require(tokens <= balances[msg.sender], "You doesn't have enough tokens on the balance");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    /** 
    * @notice Transfer tokens from the @param from account to the @param to account
    * 
    * The calling account must already have sufficient tokens approve(...)-d
    * for spending from the from account and
    * @param from account must have sufficient balance to transfer
    * @param to - Spender must have sufficient allowance to transfer
    * @param tokens - 0 value transfers are allowed
    * @return Whether the transfer was successful or not
    */
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool) {
        require(to != address(0), "Disallow transfer to 0 address");
        require(tokens <= balances[from], "You doesn't have enough tokens on the balance");
        require(tokens <= allowed[from][msg.sender], "You doesn't have enough allowed tokens");
        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }


    /// @notice Returns the amount of tokens approved by the 
    /// @param tokenOwner that can be transferred to the 
    /// @param spender's account
    function allowance(address tokenOwner, address spender) public override view returns (uint256) {
        require(spender != address(0), "Disallow transfer to 0 address");
        return allowed[tokenOwner][spender];
    }



  /**
   * @dev Function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param amount The amount that will be created.
   */
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Disallow transfer to 0 address");
        total_supply = total_supply + amount;
        balances[account] = balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }



  /**
   * @dev Internal function that burns an amount of the token of a given account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Disallow transfer from 0 address");
        require(amount <= balances[account], "Address doesn't have enough tokens on the balance");
        total_supply = total_supply - amount;
        balances[account] = balances[account] - amount;
        emit Transfer(account, address(0), amount);        
    }
}