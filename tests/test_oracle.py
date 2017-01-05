# -*- coding: utf8 -*-
import pytest
import time
from os.path import dirname, abspath, join, realpath

from ethereum import tester
from ethereum.tester import ABIContract, ContractTranslator, TransactionFailed


def get_contract_path(contract_name):
    project_directory = dirname(dirname(abspath(__file__)))
    contract_path = join(project_directory, 'smart_contracts', contract_name)
    return realpath(contract_path)


def test_oracle():
    oracle_path = get_contract_path('Oracle.sol')

    state = tester.state()
    oracle = state.abi_contract(
        None,
        path=oracle_path,
        language='solidity',
        # constructor_parameters=[tester.a0.encode('hex')],
    )

    assert oracle.owner() == tester.a0.encode('hex')
    oracle.update(int(time.time()), 123)

    assert oracle.getDate() == int(time.time())
    assert oracle.getRate() == 123
