# `DEROMultisig`: Multisig Implementation SmartContract
Finite version of multisig wallet concept


Use the officialy hosted contract here:
https://plrspro.github.io/dero-sc-multisig/interface/


Read through development log:
https://forum.dero.io/t/wip-dero-multisig-smart-contract/942



- Step 1

to be able to use interface, please run dero wallet and daemon with these params
```
start derod-windows-386.exe --testnet
start dero-wallet-cli-windows-386.exe --wallet-file test1.wallet --testnet --rpc-server --rpc-bind=127.0.0.1:30307
```


- Step 2

You can run your electron interface app with (You need to have Node.Js installed)
```
cd ../interface
npm install
npm run start
```

or use web hosted version
```
https://plrspro.github.io/dero-sc-multisig/interface/
```

or clone repo and run while computer isolated from public internet
```
interface/index.html
```

or interact directly via curl

- Step 3

How to use with Electron App (GUI): [Video Guide Here](https://plrspro.github.io/dero-sc-multisig/interface/)

How to use with Wallet (CLI) further down


