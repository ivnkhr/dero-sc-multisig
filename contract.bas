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
	20  PRINTF("  |  `DEROMultisig    |  ")
	30  PRINTF("  |                   |  ")
	40  PRINTF("  | "+info_message        )
	50  PRINTF("  |                   |  ")
	60  PRINTF("  +-------------------+  ")
	70  PRINTF("  + TXID: "+TXID()        )
	80  PRINTF("  +-------------------+  ")
	
	999 RETURN 0
End Function 


Function Error(error_message String) Uint64 

	10  PRINTF("  +-----[ ERROR ]-----+  ")
	20  PRINTF("  |  `DEROMultisig    |  ")
	30  PRINTF("  |                   |  ")
	40  PRINTF("  | "+error_message       )
	50  PRINTF("  |                   |  ")
	60  PRINTF("  +-----[ ERROR ]-----+  ")
	70  PRINTF("  + TXID: "+TXID()        )
	80  PRINTF("  +-------------------+  ")
	
	999 RETURN 1
End Function 


/* `DEROMultisig Wallet` Specific Functions */

// Creates unlocked `DEROMultisig Wallet` instance (txid represents your wallet id inside of a contract scope)
Function WalletCreate()

	01 DIM wallet, creator as String
	02 LET wallet = TXID()
	03 LET creator = SIGNER()
	
	20 STORE(wallet, creator) // Your `DEROMultisig Wallet` id, where key is txid and value is signer hash
	21 STORE(wallet+'_locked', 0) // Flag that locks wallet wich allow deposits and disables adding another signers
	22 STORE(wallet+'_balance', 0) // Starts with empty balance credited to wallet
	23 STORE(wallet+'_signer_index', 0) //First index represents creator
	24 STORE(wallet+'_signer_0', creator) //First signer will be executors address
	
	999 RETURN Info("New `DEROMultisig Wallet` ("+wallet+") successfully created.")
End Function


// Add signer to `DEROMultisig Wallet`
Function WalletAddSigner(wallet, signer)

	// Check if given DERO address (signer) is valid
	10 IF IS_ADDRESS_VALID(ADDRESS_RAW(signer)) THEN GOTO 20
	11 RETURN Error("Given signer address is not a valid DERO address.")
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	20 IF EXISTS(wallet) THEN GOTO 30
	21 RETURN Error("Given `DEROMultisig Wallet` instance does not exists in database.")
	
	// Check if contract executor have permission to interact with given `DEROMultisig Wallet` instance
	30 IF ADDRESS_RAW(LOAD(wallet)) == ADDRESS_RAW(SIGNER()) THEN GOTO 40
	31 RETURN Error("You have no permission to add signers to this `DEROMultisig Wallet` instance.")
	
	// In order to add additional signer `DEROMultisig Wallet` instance should be unlocked
	40 IF LOAD(wallet+'_locked') == 0 THEN GOTO 50
	41 RETURN Error("You are not able to add additional signer to locked `DEROMultisig Wallet` wallet.")

	50 PRINTF("  ---------------------  ")
	
	100 DIM next_signer_index as Uint64
	101 LET next_signer_index = LOAD(wallet+'_signer_index')+1
	
	110 STORE(wallet+'_signer_'+next_signer_index), ADDRESS_RAW(signer))
	111 STORE(wallet+'_signer_index', next_signer_index)
	
	999 RETURN Info("New signer ("+signer+") added to `DEROMultisig Wallet` ("+wallet+") successfully.")
End Function


//Locks `DEROMultisig Wallet` preventing new signers to be added to this wallet and allows deposits
Function WalletLock(wallet)
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance exists in database.")
	
	// In order to lock `DEROMultisig Wallet` instance should be unlocked
	20 IF LOAD(wallet+'_locked') == 0 THEN GOTO 30
	21 RETURN Error("You are not able to lock an unlocked `DEROMultisig Wallet` instance.")
	
	30 PRINTF("  ---------------------  ")
	
	100 STORE(wallet+'_locked', 1)
	
	999 RETURN Info("`DEROMultisig Wallet` ("+wallet+") is now locked.")
End Function


/* Wallet Aliases */

Function WalletCreateAndLockWithOneAdditionalSigner(signer1)

	01 DIM wallet as String
	02 LET wallet = TXID()

	10 IF WalletCreate() == 0 THEN GOTO 20
	11 RETURN 1
	
	20 IF WalletAddSigner(wallet, signer1) == 0 THEN GOTO  30
	21 RETURN 1
	
	30 IF WalletLock(wallet) == 0 THEN GOTO 40
	31 RETURN 1
	
	40 PRINTF("  ---------------------  ")
	
	999 RETURN 0
End Function


Function WalletCreateAndLockWithTwoAdditionalSigners(signer1, signer2)

	01 DIM wallet as String
	02 LET wallet = TXID()

	10 IF WalletCreate() == 0 THEN GOTO 20
	11 RETURN 1
	
	20 IF WalletAddSigner(wallet, signer1) == 0 THEN GOTO  30
	21 RETURN 1
	
	30 IF WalletAddSigner(wallet, signer2) == 0 THEN GOTO  40
	31 RETURN 1
	
	40 IF WalletLock(wallet) == 0 THEN GOTO 50
	41 RETURN 1
	
	50 PRINTF("  ---------------------  ")
	
	999 RETURN 0
End Function


Function WalletCreateAndLockWithThreeAdditionalSigners(signer1, signer2, signer3)

	01 DIM wallet as String
	02 LET wallet = TXID()

	10 IF WalletCreate() == 0 THEN GOTO 20
	11 RETURN 1
	
	20 IF WalletAddSigner(wallet, signer1) == 0 THEN GOTO  30
	21 RETURN 1
	
	30 IF WalletAddSigner(wallet, signer2) == 0 THEN GOTO  40
	31 RETURN 1
	
	40 IF WalletAddSigner(wallet, signer3) == 0 THEN GOTO  50
	41 RETURN 1
	
	50 IF WalletLock(wallet) == 0 THEN GOTO 60
	51 RETURN 1
	
	60 PRINTF("  ---------------------  ")
	
	999 RETURN 0
End Function


/* `DEROMultisig Transaction` Specific Functions */
/*
//Deposits are only allowed in locked wallets (If wallet is unlocked value will be transfered back)
Function TransactionDeposit(wallet Uint64, value Uint64) Uint64

	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance does not exists in database.")
	
	// In order to add additional signer `DEROMultisig Wallet` instance should be unlocked
	20 IF LOAD(wallet+'_locked') == 0 THEN GOTO 30
	21 RETURN Error("You are not able to add additional signer to locked `DEROMultisig Wallet` wallet.")

	30 PRINTF("  ---------------------  ")

	100 STORE(wallet+'_balance', LOAD(wallet+'_balance')+value)
	
	999 RETURN 0
End Function


//Creates a `DEROMultisig Transaction` instance ready for signing
Function TransactionCreateSend(from, destination, amount)

	//Check if wallet exists
	10 IF EXISTS(wallet) THEN GOTO 100
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")
	
	//Check if wallet exists
	20 IF EXISTS(transaction) THEN GOTO 100
	21 RETURN Error("Given `DEROMultisig Transaction` does not exists")
	
	100
	
	999 RETURN 0
End Function


//Alias to `DEROMultisig Transaction`
Function TransactionCreateWithdraw(from, amount)
	
	999 RETURN TransactionSend(from, SIGNER())
End Function


//Signs a `DEROMultisig Transaction` (when last signer will sign this transaction dero will be withdrawn)
Function TransactionSign()

	SEND_DERO_TO_ADDRESS(LOAD("depositor_address" + winner) , LOAD("lotterygiveback")*LOAD("deposit_total")/10000)
	
	999 RETURN 0
End Function
*/
