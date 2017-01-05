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
    IOU_token_path = get_contract_path('IOUToken.sol')

    state = tester.state()
    IOU_token = state.abi_contract(
        None,
        path=IOU_token_path,
        language='solidity',
        # constructor_parameters=[],
    )
