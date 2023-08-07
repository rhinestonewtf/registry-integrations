// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { SchemaResolver } from "registry/src/resolver/SchemaResolver.sol";
import "registry/src/Common.sol";
import { ModuleRegistrar } from "./ModuleRegistrar.sol";
import { ENS } from "ens-contracts/registry/ENS.sol";

/// @title SchemaResolverWithENS
/// @author zeroknots
/// @notice ContractDescription

contract SchemaResolverWithENS is SchemaResolver, ModuleRegistrar {
    constructor(
        address registry,
        ENS ensRegistry,
        bytes32 node
    )
        ModuleRegistrar(ensRegistry, node)
        SchemaResolver(registry)
    { }

    function onAttest(
        AttestationRecord calldata attestation,
        uint256 value
    )
        internal
        virtual
        override
        returns (bool)
    { }

    function onRevoke(
        AttestationRecord calldata attestation,
        uint256 value
    )
        internal
        virtual
        override
        returns (bool)
    { }

    function onModuleRegistration(
        ModuleRecord calldata module,
        uint256 value
    )
        internal
        virtual
        override
        returns (bool)
    {
        // get module name from abi encoded data
        (string memory moduleName) = abi.decode(module.data, (string));
        bytes32 ensSubNode = keccak256(abi.encodePacked(moduleName));
        _registerENS(ensSubNode, module.implementation);
        return true;
    }

    function onPropagation(
        AttestationRecord calldata attestation,
        address sender,
        address to,
        uint256 toChainId,
        address moduleOnL2
    )
        internal
        virtual
        override
        returns (bool)
    { }
}
