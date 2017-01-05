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

    oracle_path = get_contract_path('Oracle.sol')
    oracle = state.contract(
        None,
        path=oracle_path,
        language='solidity',
        # constructor_parameters=[],
    )

    IOU_token_path = get_contract_path('IOUToken.sol')
    iou_token = state.contract(
        None,
        path=IOU_token_path,
        language='solidity',
        # constructor_parameters=[],
    )

    swap_path = get_contract_path('SwapContractNew.sol')
    swap_contract = state.abi_contract(
        None,
        path=swap_path,
        language='solidity',
        libraries={'Oracle': oracle.encode('hex'), 'IOUToken': iou_token.encode('hex')},
        constructor_parameters=[oracle.encode('hex'), tester.k1, tester.k2, 1, 100, 1000000, 10, iou_token.encode('hex')],
    )



