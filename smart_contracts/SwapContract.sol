import "InterestRateOracle.sol";

contract SwapContract {

    uint global_interest_rate;
    address oracle_address;

    function SwapContract(address oracle_addr) {
        oracle_address = oracle_addr;
    }

    function updateInterestRate(bytes32 currency) {
        InterestRateOracle iro = InterestRateOracle(oracle_address);
        global_interest_rate = iro.getInterestRate(currency);
    }

    function getInterestRate() returns (uint) {
        return global_interest_rate;
    }
}
