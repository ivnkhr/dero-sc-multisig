/* 	DEROMultisig
	Multisig concept implementation on DVM-BASIC  
	by @plrspro
*/

/* Service Functions and Utility */

Function Initialize() Uint64
	
	999 RETURN Info("Contract Successfully Deployed")
End Function 


Function Info(info_message String) Uint64 

	10  PRINTF("  +-------------------+  ")
	20  PRINTF("  |   DEROMultisig    |  ")
	30  PRINTF("  |                   |  ")
	40  PRINTF("  | "+info_message       )
	50  PRINTF("  |                   |  ")
	60  PRINTF("  +-------------------+  ")
	
	999 RETURN 0
End Function 


Function Error(error_message String) Uint64 

	10  PRINTF("  +-----[ ERROR ]-----+  ")
	20  PRINTF("  |   DEROMultisig    |  ")
	30  PRINTF("  |                   |  ")
	40  PRINTF("  | "+error_message       )
	50  PRINTF("  |                   |  ")
	60  PRINTF("  +-----[ ERROR ]-----+  ")
	
	999 RETURN 1
End Function 


/* `DEROMultisig Wallet` Specific Functions */

// Creates unlocked `DEROMultisig Wallet` instance (txid represents your wallet id inside of a contract scope)
Function WalletCreate()

	01 DIM wallet as String
	02 LET wallet = TXID()
	
	20 STORE(wallet, SIGNER()) // Your `DEROMultisig Wallet` id
	21 STORE(wallet+'_locked', 0) // Flag that locks wallet wich allow deposits and disables adding another signers
	22 STORE(wallet+'_balance', 0) // Flag that locks wallet wich allow deposits and disables adding another signers
	23 STORE(wallet+'_signer_index', 0)
	24 STORE(wallet+'_signer_0', SIGNER())
	
	999 RETURN Info("New `DEROMultisig Wallet` ("+wallet+") successfully created.")
End Function


// Add signer to `DEROMultisig Wallet`
Function WalletAddSigner(wallet, signer)

	// Check if given DERO adress (signer) is valid
	10 IF IS_ADDRESS_VALID(ADDRESS_RAW(signer)) THEN GOTO 20
	11 RETURN Error("Given signer address is not a valid DERO adress")
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	20 IF EXISTS(wallet) THEN GOTO 30
	21 RETURN Error("Given `DEROMultisig Wallet` instance exists in database")
	
	// Check if contract executor have permission to interact with given `DEROMultisig Wallet` wallet
	30 IF ADDRESS_RAW(LOAD(wallet)) == ADDRESS_RAW(SIGNER()) THEN GOTO 40
	31 RETURN Error("You have no permission to add signers to this `DEROMultisig Wallet`")
	
	// In order to add additional signer `DEROMultisig Wallet` instance should be unlocked
	40 IF LOAD(wallet+'_locked') == 0 THEN GOTO 50
	41 RETURN Error("You are not able to add additional signer to locked `DEROMultisig Wallet` wallet")

	50 PRINTF("  ---------------------  ")
	
	100 DIM signer_index as Uint64
	101 LET signer_index = LOAD(wallet+'_signer_index')
	
	110 STORE(wallet+'_signer_'+(signer_index+1), ADDRESS_RAW(signer))
	111 STORE(wallet+'_signer_index', signer_index+1)
	
	999 RETURN Info("New signer ("+signer+") added to `DEROMultisig Wallet` ("+wallet+") successfully.")
End Function


//Locks `DEROMultisig Wallet` preventing new signers to be added to this wallet and allows deposits
Function WalletLock(wallet)
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance exists in database")
	
	// In order to lock `DEROMultisig Wallet` instance should be unlocked
	20 IF LOAD(wallet+'_locked') == 0 THEN GOTO 30
	21 RETURN Error("You are not able to lock an unlocked `DEROMultisig Wallet` instance")
	
	30 PRINTF("  ---------------------  ")
	
	100 STORE(wallet+'_locked', 1)
	
	999 RETURN Info("`DEROMultisig Wallet` ("+wallet+") now locked.")
End Function


/* Wallet Aliases */

Function WalletCreateAndLockWithOneAdditionalSigner()

	IF WalletCreate() == 0 THEN GOTO
	
	999 RETURN 0
End Function


Function WalletCreateAndLockWithTwoAdditionalSigners()


	999 RETURN 0
End Function


Function WalletCreateAndLockWithThreeAdditionalSigners()


	999 RETURN 0
End Function


/* `DEROMultisig Transaction` Specific Functions */

//Deposits are only allowed in locked wallets (If wallet is unlocked value will be transfered back)
Function TransactionDeposit(wallet_adress, value Uint64) Uint64

	//Check if wallet exists
	10 IF EXISTS(wallet_adress) THEN GOTO 
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")

	IF LOAD(TXID()+'_locked') == 1

	999 RETURN 0
End Function


//Creates a `DEROMultisig Transaction`
Function TransactionSend(wallet, transaction)

	//Check if wallet exists
	10 IF EXISTS(wallet) THEN GOTO 100
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")
	
	//Check if wallet exists
	20 IF EXISTS(transaction) THEN GOTO 100
	21 RETURN Error("Given `DEROMultisig Transaction` does not exists")
	
	100
	
	999 RETURN 0
End Function


//Creates a `DEROMultisig Transaction`
Function TransactionWithdraw()
	
	999 RETURN TransactionSend()
End Function


//Signs a `DEROMultisig Transaction` (when last signer will sign this transaction dero will be withdrawn)
Function TransactionSign()

	SEND_DERO_TO_ADDRESS

	
	999 RETURN 0
End Function
