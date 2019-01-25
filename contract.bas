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
	21 STORE(wallet+"_locked", 0) // Flag that locks wallet wich allow deposits and disables adding another signers
	22 STORE(wallet+"_balance", 0) // Starts with empty balance credited to wallet
	23 STORE(wallet+"_signer_index", 0) //First index represents creator
	24 STORE(wallet+"_signer_0", creator) //First signer will be executors address
	
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
	40 IF LOAD(wallet+"_locked") == 0 THEN GOTO 50
	41 RETURN Error("You are not able to add additional signer to locked `DEROMultisig Wallet` wallet.")

	50 PRINTF("  ---------------------  ")
	
	100 DIM next_signer_index as Uint64
	101 LET next_signer_index = LOAD(wallet+"_signer_index")+1
	
	110 STORE(wallet+"_signer_"+next_signer_index), ADDRESS_RAW(signer))
	111 STORE(wallet+"_signer_index", next_signer_index)
	
	999 RETURN Info("New signer ("+signer+") added to `DEROMultisig Wallet` ("+wallet+") successfully.")
End Function


//Locks `DEROMultisig Wallet` preventing new signers to be added to this wallet and allows deposits
Function WalletLock(wallet)
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance exists in database.")
	
	// In order to lock `DEROMultisig Wallet` instance should be unlocked
	20 IF LOAD(wallet+"_locked") == 0 THEN GOTO 30
	21 RETURN Error("You are not able to lock an unlocked `DEROMultisig Wallet` instance.")
	
	30 PRINTF("  ---------------------  ")
	
	100 STORE(wallet+"_locked", 1)
	
	999 RETURN Info("`DEROMultisig Wallet` ("+wallet+") is now locked.")
End Function


//Deposits are only allowed in locked wallets (If wallet is unlocked value will be transfered back)
Function WalletDeposit(wallet Uint64, value Uint64) Uint64

	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance does not exists in database.")
	
	// In order to add additional signer `DEROMultisig Wallet` instance should be unlocked
	20 IF LOAD(wallet+"_locked") == 0 THEN GOTO 30
	21 RETURN Error("You are not able to add additional signer to locked `DEROMultisig Wallet` wallet.")

	30 PRINTF("  ---------------------  ")

	100 STORE(wallet+"_balance", LOAD(wallet+'_balance')+value)
	
	999 RETURN Info("`DEROMultisig Wallet` ("+wallet+") succsesfully credited with "+value+" DERO.")
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

//Creates a `DEROMultisig Transaction` instance ready for signing
Function TransactionCreateSend(wallet, destination, amount)

	//Check if wallet exists
	10 IF EXISTS(wallet) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")
	
	// Check if dest is valid
	20 IF IS_ADDRESS_VALID(ADDRESS_RAW(LOAD(destination))) THEN GOTO 30
	21 RETURN Error("You have no permission to add signers to this `DEROMultisig Wallet` instance.")

	// Amount is valid (>0)
	30 IF amount > 0 THEN GOTO 40
	31 RETURN Error("Amount should be greater then zero")
	
	// Amount exists on the balance
	40 IF LOAD(wallet+"_balance") - amount >= 0 THEN GOTO 40
	41 RETURN Error("The amount of DERO you requested exceeding amount in `DEROMultisig Wallet` instance.")
	
	// is Wallet member
	50 DIM signer_iterator, is_valid as Uint64
	51 LET signer_iterator = LOAD(wallet+"_signer_index")+1
	53 signer_iterator = signer_iterator - 1
	54 IF LOAD(wallet+"_signer_"+signer_iterator) != SIGNER() THEN GOTO 46
	55 GOTO 50
	56 IF signer_iterator > 0 THEN GOTO 43
	58 RETURN Error("You are not a valid signer of this `DEROMultisig Wallet` instance.")
	
	60 PRINTF("  ---------------------  ")
	
	100 DIM transaction as String
	101 LET transaction = TXID()
	
	102 STORE("transaction_"+transaction, destination)
	103 STORE("transaction_"+transaction+"_amount", amount)
	103 STORE("transaction_"+transaction+"_wallet", wallet)
	104 STORE("transaction_"+transaction+"_executed", 0)
	
	999 RETURN RETURN Info("`DEROMultisig Transaction` ("+transaction+") succsesfully created.")
End Function


//Alias to `DEROMultisig Transaction`
Function TransactionCreateWithdraw(wallet, amount)
	
	999 RETURN TransactionSend(wallet, SIGNER())
End Function


//Signs a `DEROMultisig Transaction` (when last signer will sign this transaction dero will be withdrawn)
Function TransactionSign(transaction)

	//Check if transaction exists
	10 IF EXISTS("transaction_"+transaction) THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Transaction` does not exists")
	
	//Check if transaction still open
	20 IF LOAD("transaction_"+transaction+"_executed") == 0 THEN GOTO 30
	21 RETURN Error("Given `DEROMultisig Transaction` does not exists")
	
	// Valid amount is still valid
	30 IF LOAD(LOAD("transaction_"+transaction+"_wallet")+"_balance") - LOAD("transaction_"+transaction+"_amount") >= 0 THEN GOTO 30
	31 STORE("transaction_"+transaction+"_executed", 2)
	32 RETURN Error("The amount of DERO you requested exceeding amount in `DEROMultisig Wallet` instance, transaction no longer valid.")
	
	// Wallet member
	30 DIM signer_iterator as Uint64
	31 LET signer_iterator = LOAD(wallet+"_signer_index")+1
	32 signer_iterator = signer_iterator - 1
	33 IF LOAD(wallet+"_signer_"+signer_iterator) != SIGNER() THEN GOTO 35
	34 GOTO 40
	35 IF signer_iterator > 0 THEN GOTO 32
	36 RETURN Error("You are not a valid signer of this `DEROMultisig Wallet` instance.")
	
	40 PRINTF("  ---------------------  ")
	
	//Sign tourself
	100 STORE("transaction_"+transaction+"_signer_"+signer_iterator, BLID()) //First signer will be executors address
	
	// Check if all signers signed this tranaction, if so execute and close transaction
	30 DIM signed_iterator, signed_count as Uint64
	31 LET signed_iterator = LOAD(wallet+"_signer_index")+1
	32 LET signed_count = 0
	111 signed_iterator = signed_iterator - 1
	112 IF EXISTS("transaction_"+transaction+"_signer_"+signed_iterator) == 1 THEN GOTO 114
	113 signed_count = signed_count + 1
	114 IF signed_iterator > 0 THEN GOTO 33
	115 IF signed_count != LOAD(wallet+"_signer_index")+1 THEN GOTO 1000
	116 SEND_DERO_TO_ADDRESS(ADDRESS_RAW(LOAD("transaction_"+transaction)))
	104 STORE("transaction_"+transaction+"_executed", 1)
	117 RETURN RETURN Info("`DEROMultisig Transaction` ("+transaction+") signed by last member and executed.")
	
	999 RETURN RETURN Info("`DEROMultisig Transaction` ("+transaction+") signed successfully.")
End Function
*/
