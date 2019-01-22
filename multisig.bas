/* Multisig concept implementation on DVM-BASIC  
   by @plrspro
*/

/* Service Functions and Utility */

Function Initialize() Uint64
	
	10  PRINTF("  ******************  ")
	20  PRINTF("  *  ")
	30  PRINTF("  *  ")
	40  PRINTF("  *  ")
	50  PRINTF("  ******************  ")
	
End Function 

/* Wallet Specific Functions */

//Creates unlocked wallet (txid represents your wallet inside of a contract)
Function WalletCreate()

	STORE(TXID()) //Your wallet address
	STORE(TXID()+'_locked',0) //Flag that locks wallet wich allow deposits and disables adding another signers
	
End Function


Function WalletAddSigner(signerAdress)
	
	//Signer cannot be added to locked wallet
	
	rawSignerAdress = ADDRESS_RAW(signerAdress)
	IS_ADDRESS_VALID(rawSignerAdress)
	STORE(TXID()+'_signer_index',0)
	STORE(TXID()+'_signer_0',rawSignerAdress)
	
End Function


//Locks wallet preventing new signers to be added to this wallet and allows deposits
Function WalletLock()
	
	STORE(TXID()+'_locked',1)
	
End Function


/* Wallet Aliases */

Function WalletCreateAndLockWithOneAdditionalSigner()

Function WalletCreateAndLockWithTwoAdditionalSigners()

Function WalletCreateAndLockWithThreeAdditionalSigners()


/* Transaction Specific Functions */

//Deposits are only allowed in locked wallets (If wallet is unlocked value will be transfered back)
Function TransactionDeposit()


End Function


//Creates a transaction (when last signer will sign this transaction dero will be withdrawn)
Function TransactionWithdraw()

	SEND_DERO_TO_ADDRESS
	
End Function


Function TransactionSign()



End Function
