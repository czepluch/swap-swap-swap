# -*- coding: utf8 -*-
import pytest
from os.path import dirname, abspath, join, realpath

from ethereum import tester
from ethereum.tester import ABIContract, ContractTranslator, TransactionFailed


def get_contract_path(contract_name):
    project_directory = dirname(dirname(abspath(__file__)))
    contract_path = join(project_directory, 'smart_contracts', contract_name)
    return realpath(contract_path)


def test_swap_contract():
    state = tester.state()

    oracle_path = get_contract_path('InterestRateOracle.sol')
    oracle = state.contract(
        None,
        path=oracle_path,
        language='solidity',
        # constructor_parameters=[],
    )

    swap_path = get_contract_path('SwapContract.sol')
    swap_contract = state.abi_contract(
        None,
        path=swap_path,
        language='solidity',
        libraries={'SwapContract': oracle.encode('hex')},
        constructor_parameters=[oracle],
    )

    swap_contract.updateInterestRate("USD", sender=tester.k0)
    assert swap_contract.getInterestRate() == 135
    swap_contract.updateInterestRate("EUR", sender=tester.k0)
    assert swap_contract.getInterestRate() == 129
    swap_contract.updateInterestRate("NON", sender=tester.k0)
    assert swap_contract.getInterestRate() == 133

