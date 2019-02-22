/* 	DEROMultisig
	Multisig concept implementation on DVM-BASIC  
	by @plrspro
*/

/* Service Functions and Utility */

Function Initialize() Uint64
	
	999 RETURN Info("Contract Successfully Deployed")
End Function 


Function Info(info_message String) Uint64 

	01 DIM txid as String
	02 LET txid = TXID()

	10  PRINTF "  +-------------------+  " 
	20  PRINTF "  |  `DEROMultisig    |  " 
	30  PRINTF "  |                   |  " 
	40  PRINTF "  | %s" info_message
	50  PRINTF "  |                   |  " 
	60  PRINTF "  +-------------------+  " 
	70  PRINTF "  + TXID: %s" txid
	80  PRINTF "  +-------------------+  " 
	
	999 RETURN 0
End Function 


Function Error(error_message String) Uint64 

	01 DIM txid as String
	02 LET txid = TXID()

	10  PRINTF "  +-----[ ERROR ]-----+  " 
	20  PRINTF "  |  `DEROMultisig    |  " 
	30  PRINTF "  |                   |  " 
	40  PRINTF "  | %s" error_message
	50  PRINTF "  |                   |  " 
	60  PRINTF "  +-----[ ERROR ]-----+  " 
	70  PRINTF "  + TXID: %s" txid
	80  PRINTF "  +-------------------+  " 
	
	999 RETURN 1
End Function 


/* `DEROMultisig Wallet` Specific Functions */

// Creates unlocked `DEROMultisig Wallet` instance (txid represents your wallet id inside of a contract scope)
Function WalletCreate() Uint64

	01 DIM wallet, creator as String
	02 LET wallet = TXID()
	03 LET creator = SIGNER()
	
	20 STORE(wallet, creator) // Your `DEROMultisig Wallet` id, where key is txid and value is signer address
	21 STORE(wallet+"_locked", 0) // Flag that locks wallet wich allow deposits and disables adding another signers
	22 STORE(wallet+"_balance", 0) // Defines a balance of a wallet
	23 STORE(wallet+"_signer_index", 0) // First signer list index represents creator
	24 STORE(wallet+"_signer_0", creator) //First signer will be executors address
	
	999 RETURN Info("New `DEROMultisig Wallet` ("+wallet+") successfully created.")
End Function


// Add signer to `DEROMultisig Wallet`
Function WalletAddSigner(wallet String, signer String) Uint64

	// Check if given DERO address (signer) is valid
	10 IF IS_ADDRESS_VALID(signer) == 1 THEN GOTO 20
	11 RETURN Error("Given signer address ("+signer+") is not a valid DERO address.")
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	20 IF EXISTS(wallet) == 1 THEN GOTO 30
	21 RETURN Error("Given `DEROMultisig Wallet` ("+wallet+") instance does not exists in database.")
	
	// Check if contract executor have permission to interact with given `DEROMultisig Wallet` instance
	30 IF ADDRESS_RAW(LOAD(wallet)) == ADDRESS_RAW(SIGNER()) THEN GOTO 40
	31 RETURN Error("You have no permission to add signers to this `DEROMultisig Wallet` instance.")
	
	// In order to add additional signer `DEROMultisig Wallet` instance should be unlocked
	40 IF LOAD(wallet+"_locked") == 0 THEN GOTO 50
	41 RETURN Error("You are not able to add additional signer to locked `DEROMultisig Wallet` instance.")
	
	// Prevent adding same signer twice
	50 DIM signer_iterator as Uint64
	51 LET signer_iterator = LOAD(wallet+"_signer_index") + 1
	
	52 LET signer_iterator = signer_iterator - 1
	53 IF ADDRESS_RAW(LOAD(wallet+"_signer_"+signer_iterator)) != ADDRESS_RAW(signer) THEN GOTO 55
	54 RETURN Error("You cannot add the same signer to `DEROMultisig Wallet` instance twice.")
	55 IF signer_iterator > 0 THEN GOTO 52
	
	60 PRINTF "  ---------------------  "
	
	100 DIM next_signer_index as Uint64
	101 LET next_signer_index = LOAD(wallet+"_signer_index") + 1
	
	110 STORE(wallet+"_signer_"+next_signer_index, signer)
	111 STORE(wallet+"_signer_index", next_signer_index)
	
	999 RETURN Info("New signer ("+signer+") added to `DEROMultisig Wallet` ("+wallet+") successfully.")
End Function


//Locks `DEROMultisig Wallet` preventing new signers to be added to this wallet and allows deposits
Function WalletLock(wallet String) Uint64
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) == 1 THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance does not exists in database.")
	
	// Check if contract executor have permission to interact with given `DEROMultisig Wallet` instance
	20 IF ADDRESS_RAW(LOAD(wallet)) == ADDRESS_RAW(SIGNER()) THEN GOTO 30
	21 RETURN Error("You have no permission to lock this `DEROMultisig Wallet` instance.")
	
	// In order to lock `DEROMultisig Wallet` instance should be unlocked
	30 IF LOAD(wallet+"_locked") == 0 THEN GOTO 40
	31 RETURN Error("You are not able to lock an already locked `DEROMultisig Wallet` instance.")
	
	40 PRINTF "  ---------------------  "
	
	100 STORE(wallet+"_locked", 1)
	
	999 RETURN Info("`DEROMultisig Wallet` ("+wallet+") is now locked.")
End Function


//Deposits are only allowed in locked wallets (If wallet is unlocked value will be transfered back)
Function WalletDeposit(wallet String, value Uint64) Uint64

	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) == 1 THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` instance does not exists in database.")
	
	// In order to deposit to `DEROMultisig Wallet` instance it should be locked
	20 IF LOAD(wallet+"_locked") == 1 THEN GOTO 30
	21 RETURN Error("You are not able deposit into unlocked `DEROMultisig Wallet` instance.")

	30 PRINTF "  ---------------------  "

	100 DIM new_balance as Uint64
	101 LET new_balance = LOAD(wallet+"_balance") + value
	102 STORE(wallet+"_balance", new_balance)
	
	999 RETURN Info("`DEROMultisig Wallet` ("+wallet+") succsesfully credited with "+(value/1000000000000)+" DERO. Total equals to "+(new_balance/1000000000000)+" DERO.")
End Function


/* Wallet Creation Aliases */

//Alias to instantly Create, Add 1 Signer and Lock within 1 transaction
Function WalletCreateAndLockWithOneAdditionalSigner(signer1 String, value Uint64) Uint64

	01 DIM wallet as String
	02 LET wallet = TXID()

	10 IF WalletCreate() == 0 THEN GOTO 20
	11 RETURN 1
	
	20 IF WalletAddSigner(wallet, signer1) == 0 THEN GOTO  30
	21 RETURN 1
	
	30 IF WalletLock(wallet) == 0 THEN GOTO 40
	31 RETURN 1
	
	40 IF WalletDeposit(wallet, value) == 0 THEN GOTO 50
	41 RETURN 1
	
	50 PRINTF "  ---------------------  "
	
	999 RETURN 0
End Function


//Alias to instantly Create, Add 2 Signers and Lock within 1 transaction
Function WalletCreateAndLockWithTwoAdditionalSigners(signer1 String, signer2 String) Uint64

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
	
	50 IF WalletDeposit(wallet, value) == 0 THEN GOTO 60
	51 RETURN 1
	
	60 PRINTF "  ---------------------  "
	
	999 RETURN 0
End Function


//Alias to instantly Create, Add 3 Signers and Lock within 1 transaction
Function WalletCreateAndLockWithThreeAdditionalSigners(signer1 String, signer2 String, signer3 String) Uint64

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
	
	60 IF WalletDeposit(wallet, value) == 0 THEN GOTO 70
	61 RETURN 1
	
	70 PRINTF "  ---------------------  "
	
	999 RETURN 0
End Function


//Alias to instantly Create, Add 4 Signers and Lock within 1 transaction
Function WalletCreateAndLockWithFourAdditionalSigners(signer1 String, signer2 String, signer3 String, signer4 String) Uint64

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
	
	50 IF WalletAddSigner(wallet, signer4) == 0 THEN GOTO  60
	51 RETURN 1
	
	60 IF WalletLock(wallet) == 0 THEN GOTO 70
	61 RETURN 1
	
	70 IF WalletDeposit(wallet, value) == 0 THEN GOTO 80
	71 RETURN 1
	
	80 PRINTF "  ---------------------  "
	
	999 RETURN 0
End Function


//Alias to instantly Create, Add 5 Signers and Lock within 1 transaction
Function WalletCreateAndLockWithFiveAdditionalSigners(signer1 String, signer2 String, signer3 String, signer4 String, signer5 String) Uint64

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
	
	50 IF WalletAddSigner(wallet, signer4) == 0 THEN GOTO  60
	51 RETURN 1
	
	60 IF WalletAddSigner(wallet, signer4) == 0 THEN GOTO  70
	61 RETURN 1
	
	70 IF WalletLock(wallet) == 0 THEN GOTO 80
	71 RETURN 1
	
	80 IF WalletDeposit(wallet, value) == 0 THEN GOTO 90
	81 RETURN 1
	
	90 PRINTF "  ---------------------  "
	
	999 RETURN 0
End Function


/* `DEROMultisig Transaction` Specific Functions */

//Creates a `DEROMultisig Transaction` instance ready for signing
Function TransactionCreateSend(wallet String, destination String, amount Uint64) Uint64

	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) == 1 THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")
	
	// Check if destination wallet is valid DERO address
	20 IF IS_ADDRESS_VALID(destination) == 1 THEN GOTO 30
	21 RETURN Error("Destiantion address is not a valid DERO address.")

	// Check if amount is larger then zero
	30 IF amount > 0 THEN GOTO 40
	31 RETURN Error("Amount should be greater then zero.")
	
	// Check if amount exist on `DEROMultisig Wallet` balance
	40 DIM wallet_balance as Uint64
	41 LET wallet_balance = LOAD(wallet+"_balance")
	42 IF wallet_balance - amount >= 0 THEN GOTO 50
	43 RETURN Error("The amount of DERO you requested to send ("+(amount/1000000000000)+") exceeding amount in `DEROMultisig Wallet` ("+(wallet_balance/1000000000000)+") instance balance.")
	
	// Check if signer is valid member of a given `DEROMultisig Wallet`, so he can create transactions
	50 DIM signer_iterator as Uint64
	51 LET signer_iterator = LOAD(wallet+"_signer_index") + 1
	
	52 LET signer_iterator = signer_iterator - 1
	53 IF ADDRESS_RAW(LOAD(wallet+"_signer_"+signer_iterator)) != ADDRESS_RAW(SIGNER()) THEN GOTO 55
	54 GOTO 60
	55 IF signer_iterator > 0 THEN GOTO 52
	56 RETURN Error("You are not a valid member (signer) of this `DEROMultisig Wallet` instance.")
	
	60 PRINTF("  ---------------------  ")
	
	100 DIM transaction as String
	101 LET transaction = TXID()
	
	102 STORE("transaction_"+transaction, destination)
	103 STORE("transaction_"+transaction+"_amount", amount)
	104 STORE("transaction_"+transaction+"_wallet", wallet)
	105 STORE("transaction_"+transaction+"_executed", 0) // 0 - transaction open, 1 - transaction successfully executed, 2 - transaction rejected (insuffisient balance)
	106 STORE("transaction_"+transaction+"_signatures_count", 0)
	
	//Presign transaction with your signature to save executions
	107 TransactionSign(transaction)
	
	999 RETURN Info("`DEROMultisig Transaction` ("+transaction+") succsesfully created.")
End Function


//Alias to `DEROMultisig Transaction`
Function TransactionCreateWithdraw(wallet String, amount Uint64) Uint64
	
	999 RETURN TransactionCreateSend(wallet, SIGNER(), amount)
End Function


//Alias to `DEROMultisig Transaction` with human readable amount eg 4 Dero instead of 4000000000000
Function TransactionCreateSendHumanReadableAmount(wallet String, destination String, amount Uint64) Uint64
	
	// Converting human readable dero amount into blockchain precise
	01 LET amount = amount * 1000000000000
	
	999 RETURN TransactionCreateSend(wallet, destination, amount)
End Function


//Alias to `DEROMultisig Transaction` withdraw with human readable amount
Function TransactionCreateWithdrawHumanReadableAmount(wallet String, amount Uint64) Uint64
	
	999 RETURN TransactionCreateSendHumanReadableAmount(wallet, SIGNER(), amount)
End Function


//Signs a `DEROMultisig Transaction` (when last signer will sign this transaction dero will be withdrawn)
Function TransactionSign(transaction String) Uint64

	// Check if given `DEROMultisig Transaction` instance exists in database
	10 IF EXISTS("transaction_"+transaction) == 1 THEN GOTO 20
	11 RETURN Error("Given `DEROMultisig Transaction` does not exists.")
	
	// Check if `DEROMultisig Transaction` still open
	20 IF LOAD("transaction_"+transaction+"_executed") == 0 THEN GOTO 30
	21 RETURN Error("Given `DEROMultisig Transaction` is already executed.")
	
	// Check if amount exist on `DEROMultisig Wallet` balance
	30 DIM wallet as String
	31 LET wallet = LOAD("transaction_"+transaction+"_wallet")
	32 DIM wallet_balance as Uint64
	33 LET wallet_balance = LOAD(wallet+"_balance")
	
	34 IF wallet_balance - LOAD("transaction_"+transaction+"_amount") >= 0 THEN GOTO 40
	35 STORE("transaction_"+transaction+"_executed", 2)
	36 RETURN Error("The amount of DERO you requested exceeding amount in `DEROMultisig Wallet` instance bslsnvr, transaction no longer valid.")
	
	// Check if signer is valid member of a given `DEROMultisig Transaction`
	40 DIM signer_iterator as Uint64
	41 LET signer_iterator = LOAD(wallet+"_signer_index") + 1
	
	42 LET signer_iterator = signer_iterator - 1
	43 IF ADDRESS_RAW(LOAD(wallet+"_signer_"+signer_iterator)) != ADDRESS_RAW(SIGNER()) THEN GOTO 45
	44 GOTO 50
	45 IF signer_iterator > 0 THEN GOTO 42
	46 RETURN Error("You are not a valid signer of this `DEROMultisig Transaction` instance.")
	
	50 IF EXISTS("transaction_"+transaction+"_signer_"+signer_iterator) == 1 THEN GOTO 60
	51 RETURN Error("This `DEROMultisig Transaction` is already signed by you.")
	
	60 PRINTF("  ---------------------  ")
	
	// Previous checkup will find signers index and next operation will set a heigh on wich signer confirmed this transaction
	100 STORE("transaction_"+transaction+"_signer_"+signer_iterator, BLOCK_HEIGHT()) //First signer will be executors address
	
	// Check if current signer is the last signer of this `DEROMultisig Transaction`, if so execute and close transaction with status 1 (successfully executed)
	110 DIM signed_iterator, signed_count as Uint64
	111 LET signed_iterator = LOAD(wallet+"_signer_index") + 1
	112 LET signed_count = 0
	
	120 LET signed_iterator = signed_iterator - 1
	121 IF EXISTS("transaction_"+transaction+"_signer_"+signed_iterator) == 0 THEN GOTO 123
	122 LET signed_count = signed_count + 1
	123 IF signed_iterator > 0 THEN GOTO 120
	124 STORE("transaction_"+transaction+"_signatures_count", signed_count)
	125 IF signed_count != LOAD(wallet+"_signer_index")+1 THEN GOTO 999
	
	126 SEND_DERO_TO_ADDRESS(LOAD("transaction_"+transaction), LOAD("transaction_"+transaction+"_amount"))
	127 STORE("transaction_"+transaction+"_executed", 1)
	128 STORE(wallet+"_balance", wallet_balance - LOAD("transaction_"+transaction+"_amount"))
	
	998 RETURN Info("`DEROMultisig Transaction` ("+transaction+") signed by last member and now executed.")
	
	999 RETURN Info("`DEROMultisig Transaction` ("+transaction+") signed successfully.")
End Function

