from sys import exec_prefix
from web3 import Web3

import json

config = json.load(open('./config.json'))
w3 = Web3(Web3.HTTPProvider(f'http://{config["node2"]["ip"]}:{config["node2"]["port"]}'))
contract = w3.eth.contract(address=config["contract"]["address"], abi=config["contract"]["abi"])

if w3.isConnected():
    print("OK")
else:
    print("Not okey")
    exit(1)
print(contract.all_functions())

# включение аккаунта
def unlock(acc, key):
    account = Web3.toChecksumAddress(acc)
    w3.eth.default_account = account
    w3.geth.personal.unlock_account(acc, key, 10)

# авторизация
def auth(acc, key, login, password):
    try:
        w3.eth.default_account = w3.toChecksumAddress(acc)
        res = contract.functions.auth().call
        return res, None
    except Exception as e:
        return None, str(e)

# регистрация водителя
def reg(acc, key, FIO, login, password):
    try:
        unlock(acc, key)
        res = contract.functions.reg(FIO, login, password).transact
        return True, None
    except Exception as e:
        return False, str(e)
# регистрция транспортного средства
def reg_transpot(acc):
    try:
        w3.eth.default_account = w3.toChecksumAddress(acc)
        res = contract.functions.reg_t()
        return True
    except Exception as e:
        return str(e)
    

def takeOutInsurance(acc, key):
    try:
        unlock(acc, key)
        res = contract.functions.takeOutInsurance().transact
        return res
    except Exception as e:
        return str(e)

def sendRequests(acc, key):
    try:
        unlock(acc, key)
        res = contract.functions.sendRequests().call
        return res
    except Exception as e:
        return str(e)
