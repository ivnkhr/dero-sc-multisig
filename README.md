# `DEROMultisig`: Multisig Implementation SmartContract

`Contract is designed to enable multisig controll over the same funds, with multiple parties requred to approve outgoing transactions`


Finite version of multisig wallet concept

DOWNLOAD:

https://youtu.be/-3wagBUybBI

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

**How to use with Electron App (GUI)**: [Video Guide Here](https://plrspro.github.io/dero-sc-multisig/interface/)

How to use with Wallet (CLI) further down

1. Create a multisig wallet
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"WalletCreate\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\"}}}"
```

2. Add another participant (signer) to a wallet
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"WalletAddSigner\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\",\"params\":{\"wallet\":\"<CONTRACT WALLET ADDRESS (WalletCreate TXID)>\",\"signer\":\"<VALID DERO ADDRESS>\"}}}}"
```

3. Lock wallet (you will not be able to add any prticipants after, but will be allowed to deposit funds)
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"WalletLock\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\",\"params\":{\"wallet\":\"<CONTRACT WALLET ADDRESS (WalletCreate TXID)>\"}}}}"
```

4. Deposit some dero to your shared wallet
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"WalletDeposit\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\",\"params\":{\"wallet\":\"<CONTRACT WALLET ADDRESS (WalletCreate TXID)>\"},\"value\":1000000000000}}}"
```

`Alternativly you can use 1 tx aliases (create, add signer(s), lock, deposit)`
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"WalletCreateAndLockWithOneAdditionalSigner\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\",\"params\":{\"signer1\":\"<VALID DERO ADDRESS>\"},\"value\":1000000000000}}}"
```
*WalletCreateAndLockWithOneAdditionalSigner* (for you and 1 additional signer)

*WalletCreateAndLockWithTwoAdditionalSigners* (for you and 2 additional signer)

*WalletCreateAndLockWithThreeAdditionalSigners* (for you and 3 additional signer)

*WalletCreateAndLockWithFourAdditionalSigners* (for you and 4 additional signer)

*WalletCreateAndLockWithFiveAdditionalSigners* (for you and 5 additional signer)

5. Now you can create transactions (wich everyone needs to sign via (TransactionSign) method in order to be executed
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"TransactionCreateSend\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\",\"params\":{\"wallet\":\"<CONTRACT WALLET ADDRESS (WalletCreate TXID)>\",\"destination\":\"<VALID DERO ADDRESS>\",\"amount\":\"1000000000000\"}}}}"
```

6. TXID of previous operation is your transaction id, share it to everyone who needs to sign it, to approve
```
curl -X POST http://127.0.0.1:30307/json_rpc -H "Content-Type: application/json" -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"transfer_split\",\"params\":{\"mixin\":5,\"get_tx_key\":true,\"sc_tx\":{\"entrypoint\":\"TransactionSign\",\"scid\":\"4036c7ae3c0be674174d395a8c77fedb859b86e4b8dbe2279ac06d6b38764140\",\"params\":{\"transaction\":\"<TRANSACTION ID>\"}}}}"
```
