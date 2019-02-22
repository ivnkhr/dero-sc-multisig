# `DEROMultisig`: Multisig Implementation SmartContract
Finite version of multisig wallet concept


Use the officialy hosted contract here:
https://plrspro.github.io/dero-sc-multisig/interface/


Read through development log:
https://forum.dero.io/t/wip-dero-multisig-smart-contract/942


You can run your electron interface app with
```
cd ../interface
npm install
npm run start
```

to be able to use interface, please run dero wallet and daemon with these params
```
start derod-windows-386.exe --testnet
start dero-wallet-cli-windows-386.exe --wallet-file test1.wallet --testnet --rpc-server --rpc-bind=127.0.0.1:30307
```
