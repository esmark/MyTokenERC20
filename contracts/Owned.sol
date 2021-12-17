//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;


contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Transfers ownership of the contract to
     * @param newOwner - a new account.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address shouldn't be 0");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}