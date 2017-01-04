# -*- coding: utf8 -*-
import pytest
from os.path import dirname, abspath, join, realpath

from ethereum import tester
from ethereum.tester import ABIContract, ContractTranslator, TransactionFailed


def get_contract_path(contract_name):
    project_directory = dirname(dirname(abspath(__file__)))
    contract_path = join(project_directory, 'smart_contracts', contract_name)
    return realpath(contract_path)


def test_oracle():
    oracle_path = get_contract_path('InterestRateOracle.sol')

    state = tester.state()
    oracle = state.abi_contract(
        None,
        path=oracle_path,
        language='solidity',
        # constructor_parameters=[],
    )

    assert oracle.getInterestRate("USD") == 135
    assert oracle.getInterestRate("EUR") == 129
    assert oracle.getInterestRate("US") == 133
