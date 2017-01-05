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
    oracle_contract = state.abi_contract(
        None,
        path=oracle_path,
        language='solidity',
        # constructor_parameters=[],
    )

    IOU_token_path = get_contract_path('IOUToken.sol')
    iou_token = state.abi_contract(
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
        libraries={'Oracle': oracle_contract.address.encode('hex'), 'IOUToken': iou_token.address.encode('hex')},
        constructor_parameters=[200, oracle_contract.address.encode('hex'), tester.a1, tester.a2, 1, 100, 1000000, 10, iou_token.address.encode('hex')],
    )

    oracle_contract.update(11, 350)
    iou_token.approveAccount(swap_contract.address)
    assert iou_token.balanceOf(tester.a1) == 0
    assert iou_token.balanceOf(tester.a2) == 0
    swap_contract.initiatePayment()
    assert iou_token.balanceOf(tester.a1) == 15000
    assert iou_token.balanceOf(tester.a2) == -15000

