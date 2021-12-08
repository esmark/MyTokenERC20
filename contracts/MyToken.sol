//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;


/// @title MyERC20Token token contract
/// @author Kamil Khadeyev
/// @notice You can use this ERC20 contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @notice ERC Token Standard #20 Interface
/// @notice https:///github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint);
    function transfer(address to, uint tokens) external returns (bool);
    function allowance(address tokenOwner, address spender) external view returns (uint);
    function approve(address spender, uint tokens) external returns (bool);
    function transferFrom(address from, address to, uint tokens) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/// @notice ERC20 Token, with the addition of symbol, name and decimals and assisted token transfers
/// @dev symbol of the token
/// @dev name of the token
/// @dev decimals of the token = 0
/// @dev total_supply total supply
contract MyToken is ERC20Interface {
    string public constant symbol = "MET";
    string public constant name = "My ERC20 Token";
    uint8 public constant decimals = 0;
    uint public total_supply = 100000000;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    /// @notice Constructor
    constructor() {
        balances[msg.sender] = total_supply;
        emit Transfer(address(0), msg.sender, total_supply);
    }


    /// @notice Total supply
    function totalSupply() public override view returns (uint) {
        return total_supply - balances[address(0)];
    }


    /// @notice Get the token balance for account tokenOwner
    /// @param tokenOwner is address of token owner
    function balanceOf(address tokenOwner) public override view returns (uint) {
        return balances[tokenOwner];
    }


    /// @notice Transfer the balance from token owner's account to to account
    /// @param to - address of receiver. Owner's account must have sufficient balance to transfer
    /// @param tokens - 0 value transfers are allowed
    function transfer(address to, uint tokens) public override returns (bool) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    /// @notice Token owner can approve for 
    /// @param spender to transferFrom(...) 
    /// @param tokens from the token owner's account
    ///
    /// @notice https:///github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    /// recommends that there are no checks for the approval double-spend attack
    /// as this should be implemented in user interfaces 
    function approve(address spender, uint tokens) public override returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    /// @notice Transfer tokens from the 
    /// @param from account to the 
    /// @param to account
    /// 
    /// @notice The calling account must already have sufficient tokens approve(...)-d
    /// for spending from the from account and
    /// - From account must have sufficient balance to transfer
    /// - Spender must have sufficient allowance to transfer
    /// - 0 value transfers are allowed
    function transferFrom(address from, address to, uint tokens) public override returns (bool) {
        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }


    /// @notice Returns the amount of tokens approved by the owner that can be
    /// transferred to the spender's account
    function allowance(address tokenOwner, address spender) public override view returns (uint) {
        return allowed[tokenOwner][spender];
    }
}