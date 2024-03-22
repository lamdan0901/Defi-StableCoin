// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 * This is the contract meant to be governed by DSCEngine.
 * This contract is just the ERC20 implementation of our stablecoin system.
 */
contract DecentralizedStableCoin is ERC20Burnable {
    error DecentralizedStableCoin_MustBeGreaterThanZero();
    error DecentralizedStableCoin_BurnAmountExceedsBalance();
    error DecentralizedStableCoin_NotZeroAddress();

    /**
     * A burnable coin help it maintain its peg price
     */

    // use ERC20 here cuz ERC20Burnable is ERC20
    constructor() ERC20("DecentralizedStableCoin", "DSC") {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizedStableCoin_MustBeGreaterThanZero();
        }
        if (balance <= _amount) {
            revert DecentralizedStableCoin_BurnAmountExceedsBalance();
        }

        super.burn(_amount); // this means use the 'burn' function from parent/super class
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) revert DecentralizedStableCoin_NotZeroAddress();
        if (_amount <= 0) {
            revert DecentralizedStableCoin_MustBeGreaterThanZero();
        }

        _mint(_to, _amount);
        return true;
    }
}
