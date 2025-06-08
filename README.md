# AuctionSystems
SmartContract-AuctionSystems
Description
This repository contains a fully-featured English Auction smart contract system developed in Solidity. The project demonstrates the implementation of a robust, secure, and gas-conscious auction mechanism on the Ethereum blockchain.

The system is architected using inheritance to promote code reusability and a clear separation of concerns. It includes advanced features such as a minimum bid increment, anti-sniping time extension, a beneficiary commission, and a partial refund mechanism for bidders.

Core Concepts Implemented
This project showcases a solid understanding of several core Solidity and smart contract development concepts:

Inheritance: The main EnglishAuction contract inherits from a BaseContract, separating ownership and state-management logic from the specific auction implementation.

Modifiers: Custom modifiers (onlyOwner, notFinished, auctionInProgress, etc.) are used extensively to ensure secure and clean function execution.

Events: Events are emitted for all significant state changes, allowing for efficient off-chain monitoring and dApp integration.

Error Handling: require() statements are used to validate inputs and state conditions, providing clear error messages and preventing invalid transactions.

Payable Functions: The contract correctly handles Ether transfers using payable functions and follows the Checks-Effects-Interactions pattern to prevent re-entrancy attacks.

Data Structures: Use of structs and mappings to efficiently store and manage auction data, such as bid history and individual bid amounts.

Features
English Auction Logic: Ascending-bid auction where the highest bidder at the end wins.

Minimum Bid Increment: New bids must be at least 5% higher than the current highest bid.

Anti-Sniping Extension: If a valid bid is placed within the last 10 minutes, the auction is extended by another 10 minutes.

Beneficiary Commission: A 2% commission is automatically deducted from the winning bid and retained by the contract owner.

Funds Withdrawal:

Non-winning bidders can safely withdraw their full bid amount after the auction ends.

The beneficiary (auction owner) can withdraw the proceeds from the winning bid.

Partial Refund: Bidders can withdraw previous, outbid offers during the auction, freeing up their capital.

How to Use / Deploy
This project consists of two contracts that must be used together.

Prerequisites: An environment to compile and deploy Solidity contracts, such as Remix IDE.

Files:

BaseContract.sol: The base contract handling ownership.

EnglishAuction.sol: The main contract logic.

Compilation: Compile EnglishAuction.sol using a Solidity compiler version ^0.8.20. Remix will automatically handle the import of BaseContract.sol.

Deployment:

Deploy the EnglishAuction contract.

Provide the required constructor arguments:

_durationInSeconds (uint256): The initial duration of the auction in seconds.

_beneficiary (address): The payable address that will receive the final auction proceeds.

Author
Guillermo Siaira
