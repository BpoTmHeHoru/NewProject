cd ./test/bnode
start cmd.exe /C python.exe start.py

cd ../node1
start cmd.exe /C python.exe start.py

cd ../node2
start cmd.exe /C python.exe start.py

start cmd.exe /C geth attach http://192.168.0.102:8545 --exec miner.start(1)