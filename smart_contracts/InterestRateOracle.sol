contract InterestRateOracle {

    function getInterestRate(bytes32 currency) returns (uint) {
        // call returnInterestRate with result from oracle
        return interestRate(currency);
    }

    function interestRate(bytes32 currency) private returns (uint) {
        if (currency == "USD") {
            return 135; // two decimal points
        } if (currency == "EUR") {
            return 129;
        } else {
            return 133;
        }
    }
}
