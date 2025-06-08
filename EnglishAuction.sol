// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "./BaseContract.sol";

/**
 * @title EnglishAuction
 * @author Tu Nombre
 * @notice Este contrato implementa una subasta inglesa con funcionalidades avanzadas.
 * @dev Hereda de BaseContract para gestionar la propiedad y el estado de finalización.
 */
contract EnglishAuction is BaseContract {
    // --- Variables de Estado Específicas de la Subasta ---
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;

    struct Bid {
        address bidder;
        uint amount;
        uint timestamp;
        bool refunded;
    }
    Bid[] public bidHistory;

    // --- Constantes ---
    uint public constant MIN_BID_INCREASE_PERCENTAGE = 5;
    uint public constant BENEFICIARY_COMMISSION_PERCENTAGE = 2;
    uint public constant TIME_EXTENSION_IN_SECONDS = 10 minutes;

    // --- Eventos Específicos de la Subasta ---
    event NewBid(address indexed bidder, uint amount, uint newAuctionEndTime);
    event AuctionEnded(address indexed winner, uint winningBid);
    event PartialRefund(address indexed bidder, uint refundedAmount, uint bidIndex);
    event NonWinnerFundsWithdrawn(address indexed bidder, uint withdrawnAmount);
    event BeneficiaryFundsWithdrawn(address indexed beneficiary, uint withdrawnAmount, uint commission);

    // --- Modificador Específico de la Subasta ---
    /**
     * @dev Valida que la subasta esté en curso (dentro del tiempo).
     * El modificador notFinished() del contrato base se debe aplicar por separado.
     */
    modifier auctionInProgress() {
        require(block.timestamp < auctionEndTime, "Auction: Time has expired.");
        _;
    }

    // --- Constructor ---
    /**
     * @notice Inicializa la subasta, llamando al constructor del contrato base.
     * @param _durationInSeconds Duración inicial de la subasta.
     * @param _beneficiary Dirección que recibirá los fondos (será el 'owner' del contrato base).
     */
    constructor(uint _durationInSeconds, address payable _beneficiary)
        BaseContract(_beneficiary) // Llama al constructor del BaseContract
    {
        require(_durationInSeconds > 0, "Duration must be greater than zero.");
        auctionEndTime = block.timestamp + _durationInSeconds;
    }

    // --- Funciones Principales ---

    function bid() external payable notFinished auctionInProgress {
        require(msg.value > 0, "Bid must be greater than zero.");
        uint minRequiredBid = highestBid == 0
            ? 1
            : highestBid + (highestBid * MIN_BID_INCREASE_PERCENTAGE / 100) + 1;
        require(msg.value >= minRequiredBid, "Bid does not meet the minimum increase.");

        highestBid = msg.value;
        highestBidder = msg.sender;
        bids[msg.sender] = msg.value;
        bidHistory.push(Bid(msg.sender, msg.value, block.timestamp, false));

        if (auctionEndTime - block.timestamp < TIME_EXTENSION_IN_SECONDS) {
            auctionEndTime = block.timestamp + TIME_EXTENSION_IN_SECONDS;
        }

        emit NewBid(msg.sender, msg.value, auctionEndTime);
    }

    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "It's not time to end the auction yet.");
        _finish(); // Llama a la función interna del BaseContract
        emit AuctionEnded(highestBidder, highestBid);
    }

    function withdrawNonWinnerFunds() external alreadyFinished {
        require(msg.sender != highestBidder, "The winner cannot withdraw their bid here.");
        uint amountToWithdraw = bids[msg.sender];
        require(amountToWithdraw > 0, "No funds to withdraw.");

        bids[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amountToWithdraw}("");
        require(success, "Transfer to non-winner failed.");

        emit NonWinnerFundsWithdrawn(msg.sender, amountToWithdraw);
    }

    function withdrawBeneficiaryFunds() external alreadyFinished onlyOwner {
        require(highestBid > 0, "There were no bids.");
        
        uint amountInContract = bids[highestBidder];
        require(amountInContract > 0, "Beneficiary funds already withdrawn.");

        uint commission = (amountInContract * BENEFICIARY_COMMISSION_PERCENTAGE) / 100;
        uint amountForBeneficiary = amountInContract - commission;

        bids[highestBidder] = 0;
        (bool success, ) = owner.call{value: amountForBeneficiary}(""); // 'owner' es del BaseContract
        require(success, "Transfer to beneficiary failed.");

        emit BeneficiaryFundsWithdrawn(owner, amountForBeneficiary, commission);
    }

    function partialRefund(uint _bidIndex) external notFinished {
        require(_bidIndex < bidHistory.length, "Invalid bid index.");
        Bid storage bidToRefund = bidHistory[_bidIndex];

        require(bidToRefund.bidder == msg.sender, "This is not your bid.");
        require(!bidToRefund.refunded, "Already refunded.");

        bool isTheCurrentWinningBid = bidToRefund.bidder == highestBidder && bidToRefund.amount == highestBid;
        require(!isTheCurrentWinningBid, "You cannot refund the current winning bid.");

        if (bidToRefund.bidder == highestBidder) {
            require(bidToRefund.amount < bids[msg.sender], "If you are the highest bidder, you can only refund previous, smaller bids.");
        }

        bidToRefund.refunded = true;
        (bool success, ) = msg.sender.call{value: bidToRefund.amount}("");
        require(success, "Partial refund transfer failed.");

        emit PartialRefund(msg.sender, bidToRefund.amount, _bidIndex);
    }

    // --- Funciones de Visualización (View) ---

    function getWinner() external view alreadyFinished returns (address winner, uint winningBid) {
        return (highestBidder, highestBid);
    }

    function getBidHistory() external view returns (Bid[] memory) {
        return bidHistory;
    }

    function getTimeLeft() external view returns (uint) {
        // Usa la variable 'isFinished' del contrato base
        if (isFinished || block.timestamp >= auctionEndTime) {
            return 0;
        }
        return auctionEndTime - block.timestamp;
    }
    
    function getBeneficiary() external view returns (address payable) {
        return owner;
    }
}