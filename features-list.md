
# Sentinel features list

- [Basic-Functionality:](#Basic-Functionality) 
   - [Balance screen](#Balance-screen) 
   - [Watchlist](#Watchlist)
   - [Deposit](#Deposit)
- [Settings:](#settings) 
   - [Street-price](#Street-price) 
   - [Block-explorer](#Block-explorer) 
   - [Export-wallet](#Export-wallet) 
   - [Restore-wallet](#Restore-wallet) 
   - [Use-PIN-code](#Use-PIN-code) 
   - [Scramble-PIN-entry](#Scramble-PIN-entry) 
   - [About-Sentinel](#About-Sentinel) 

## Basic-Functionality

### Balance-screen
Balance screen lists all txs as supplied by Samourai API for all XPUBs/addresses sent by app. Drop down list allows for selection of either Total (all XPUBs/addresses) or a single one.

### Watchlist
List of all entered xtended public keys/addresses with selections for:

* delete entry
* display QR code
* edit display label

Insert extended public key/address: 'type' is assumed based on entered extended public key/address:

* bitcoin address (p2pkh or p2sh)
* XPUB (BIP32/BIP44)
* YPUB (BIP49)
* ZPUB (BIP84)

User may scan QR code or enter text.

### Deposit
User selects an extended public key or bitcoin address to deposit to and is then presented with a screen display QR code, address in text format and amount entry areas in both BTC and fiat.
The QR code contains the address, either the legacy address selected or an address derived from the extended public key. When amounts are entered, the QR code changes in real-time to display a BIP21 URI.
If extended public key is selected, the receive address must correspond to the first unused address in the external chain as reported by Samourai backend API. 

## Settings

### Street-price
same exchange rates as Samourai.

* Localbitcoins.com: USD, EUR, GBP, CNY, RUR
* WEX (ex BTC-e): USD, EUR, RUR
* Bitfinex: USD

### Block-explorer
same block explorer selections as Samourai.

**MainNet:**
* Smartbit
* UASF Explorer
* Yogh
* Blockcyber

### Export-wallet
User may export encrypted payload. Payload encrypted using password defined by user at time of export.
We will use same encryption as Sentinel Android in order to assure cross-platform exhanges.

### Restore-wallet
User import previously exported backup which replaces any metadata currently used.

### Use-PIN-code
User may define PIN-code access. PIN code is 5-8 digits and times out after 15 minutes.

### Scramble-PIN-entry
User may activate scrambled PIN entry if PIN entry is chosen. Numerical keypad is randomly scrambled rather than in numerical order.

### About-Sentinel
Basic About screen.
