// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



contract BaseContract {
    address payable public owner;
    bool public isFinished;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractFinished();

    /**
     * @dev El modificador requiere que la llamada sea hecha por el propietario.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Action only for the owner");
        _;
    }

    /**
     * @dev El modificador requiere que el contrato no haya sido finalizado.
     */
    modifier notFinished() {
        require(!isFinished, "The contract has already finished");
        _;
    }
    
    /**
     * @dev El modificador requiere que el contrato ya haya sido finalizado.
     */
    modifier alreadyFinished() {
        require(isFinished, "The contract has not finished yet");
        _;
    }

    /**
     * @dev Establece la dirección del propietario al desplegar el contrato.
     */
    constructor(address payable _owner) {
        require(_owner != address(0), "Owner cannot be the zero address.");
        owner = _owner;
    }

    /**
     * @notice Permite al propietario actual transferir el control del contrato a un nuevo propietario.
     * @param _newOwner La dirección del nuevo propietario.
     */
    function transferOwnership(address payable _newOwner) public virtual onlyOwner notFinished {
        require(_newOwner != address(0), "New owner cannot be the zero address.");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * @dev Función interna para marcar el contrato como finalizado.
     * Es 'virtual' para permitir que los contratos hijos la extiendan si es necesario.
     */
    function _finish() internal virtual notFinished {
        isFinished = true;
        emit ContractFinished();
    }
}
