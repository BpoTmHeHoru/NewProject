import json
import os

config = json.load(open("../../config.json"))
os.system(f'bootnode -nodekey boot.key -addr {config["bnode"]["ip"]}:{config["bnode"]["bootport"]}')




