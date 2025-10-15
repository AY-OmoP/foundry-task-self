// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// ✅ Use only Chainlink's official interface
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * @dev Returns the latest ETH/USD price from the Chainlink price feed.
     * The price feed returns an 8-decimal value, so we scale to 18 decimals.
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        // Scale price to 18 decimals (1e10 multiplier)
        return uint256(price * 1e10);
    }

    /**
     * @dev Converts an ETH amount to USD using the price feed.
     */
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        return (ethPrice * ethAmount) / 1e18;
    }
}
