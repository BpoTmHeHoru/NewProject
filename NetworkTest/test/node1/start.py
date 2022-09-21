import json
import os

config = json.load(open("../../config.json"))
os.system(f'geth --datadir . --networkid 999 --syncmode "full" --allow-insecure-unlock --ipcdisable --http --http.addr "{config["node1"]["ip"]}" --http.port "{config["node1"]["port"]}" --http.corsdomain "*" --bootnodes "{config["bnode"]["enode"]}{config["bnode"]["ip"]}:{config["bnode"]["bootport"]}" --port "{config["node1"]["bootport"]}" --http.api web3,eth,net,personal,miner')
