// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * *Decentralize Stablecoin Engine
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg.
 * This stablecoin has the properties:
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algoritmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by WETH and WBTC.
 * @notice This contract is the core of the DSC System. It handles all the logic for mining
 * and redeeming DSC, as well as depositing & withdrawing collateral.
 * @notice This contract is VERY loosely based on the MakerDAO DSS (DAI) system.
 */
contract DSCEngine is ReentrancyGuard {
    error DSCEngine_TransferFailed();
    error DSCEngine_TokenNotAllowed();
    error DSCEngine_MustBeGreaterThanZero();
    error DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();

    mapping(address token => address priceFeed) private priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private collateralDeposited;

    modifier greaterThanZero(uint256 _amount) {
        if (_amount <= 0) revert DSCEngine_MustBeGreaterThanZero();
        _;
    }

    modifier isTokenAllowed(address _token) {
        if (priceFeeds[_token] == address(0)) {
            revert DSCEngine_TokenNotAllowed();
        }
        _;
    }

    DecentralizedStableCoin private immutable dsc;

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    constructor(address[] memory _tokenAddresses, address[] memory _priceFeedAddresses, address _dscAddress) public {
        // USD Price Feeds
        // For ex: ETH/USD, BTC/USD, ...
        if (_tokenAddresses.length != _priceFeedAddresses.length) {
            revert DSCEngine_TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
        }

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            priceFeeds[_tokenAddresses[i]] = _priceFeedAddresses[i];
        }
        dsc = DecentralizedStableCoin(_dscAddress);
    }

    function depositCollateralAndMintDsc() external {}

    /**
     * @param _tokenCollateralAddress The address of the token to deposit as collateral
     * @param _amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
        external
        greaterThanZero(_amountCollateral)
        isTokenAllowed(_tokenCollateralAddress)
        nonReentrant
    {
        collateralDeposited[msg.sender][_tokenCollateralAddress] += _amountCollateral;
        emit CollateralDeposited(msg.sender, _tokenCollateralAddress, _amountCollateral);

        bool success = IERC20(_tokenCollateralAddress).transferFrom(msg.sender, address(this), _amountCollateral);
        if (!success) revert DSCEngine_TransferFailed();
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function burnDsc() external {}
    function mintDsc() external {}
    function liquidate() external {}
    function getHealthFactor() external {}
}
