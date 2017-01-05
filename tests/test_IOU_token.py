# -*- coding: utf8 -*-
from os.path import dirname, abspath, join, realpath

import pytest
from ethereum import slogging
from ethereum import tester


def get_contract_path(contract_name):
    project_directory = dirname(dirname(abspath(__file__)))
    contract_path = join(project_directory, 'smart_contracts', contract_name)
    return realpath(contract_path)


def test_iou_token():
    iou_token_path = get_contract_path('IouToken.sol')

    state = tester.state()
    logs = list()
    iou_token = state.abi_contract(
        None,
        path=iou_token_path,
        language='solidity',
        log_listener=logs.append,
        # constructor_parameters=[],
    )

    # Test function calls
    # Test transfer function
    iou_token.transfer(5, tester.a1)
    # Test test transfer of negative amounts
    with pytest.raises(Exception):
        iou_token.transfer(-1, tester.a2)

    iou_token.approve_account(tester.a4)

    # Mine a block to receive log information about transactions
    state.mine()
    slogging.configure(":debug")
    # Checking the results of the transfer function
    assert logs[0]["amount"] == 5
    assert logs[0]["receiver"].decode('hex') == tester.a1
    assert logs[0]["sender"].decode('hex') == tester.a0
    assert iou_token.balance(tester.a0) == -5

    # Checking if all logs are available
    assert len(logs) == 2

    # Checking the approved function
    assert iou_token.is_approved(tester.a4)
    assert logs[1]["account"].decode('hex') == tester.a4

    # Disapprove approved account
    iou_token.disapprove_account(tester.a4)

    # Mine a block to really disapprove account tester.a4
    state.mine()

    # Checking the dissaprove_account function
    assert iou_token.is_approved(tester.a4) is False
    assert len(logs) == 3

    # Producing an underflow for account tester.a0
    # need to substitute 10 because I already transferred money from tester.a0 account
    iou_token.transfer(2**255-5, tester.a5)
    with pytest.raises(Exception):
        iou_token.transfer(1, tester.a4)

    # Production an overflow for account tester.a5
    with pytest.raises(Exception):
        iou_token.transfer(5, tester.a5, sender=tester.k2)
