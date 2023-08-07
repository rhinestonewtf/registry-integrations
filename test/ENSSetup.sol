// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import { ENSRegistry } from "ens-contracts/registry/ENSRegistry.sol";
import { SchemaResolverWithENS } from "../src/ENSIntegration/SchemaResolverWithENS.sol";
import { BaseRegistrarImplementation } from
    "ens-contracts/ethregistrar/BaseRegistrarImplementation.sol";
import { LibNamehash } from "../src/ENSIntegration/LibNamehash.sol";
import "registry/src/Common.sol";

/// @title ENSBaseTest
/// @author zeroknots
contract ENSBaseTest is Test {
    ENSRegistry ens;
    BaseRegistrarImplementation registrar;

    SchemaResolverWithENS rsRegistrar;

    address owner;
    address resolver;

    address controller;
    bytes32 rhinestoneNode = LibNamehash.namehash("rhinestone.eth");
    address rhinestoneOwner;

    function setUp() public {
        owner = makeAddr("owner");
        resolver = makeAddr("resolver");
        controller = makeAddr("controller");

        ens = new ENSRegistry();
        vm.warp(1_641_070_800);
        bytes32 baseNode = LibNamehash.namehash("eth");
        registrar = new BaseRegistrarImplementation(ens, baseNode);
        registrar.addController(controller);
        ens.setSubnodeOwner(0x0, keccak256("eth"), address(registrar));

        rhinestoneOwner = makeAddr("registrant");
        rsRegistrar = new SchemaResolverWithENS(makeAddr("AARegistry"),ens, rhinestoneNode);

        vm.prank(address(controller));
        registrar.register({
            id: uint256(keccak256("rhinestone")),
            owner: address(rsRegistrar),
            duration: 80 days
        });
    }

    function testSubDomainRecord() public {
        bytes32 label = keccak256("module1");
        address module1 = makeAddr("module1");

        address dev = makeAddr("dev");
        string memory moduleName = "module1";

        ModuleRecord memory moduleMockRecord = ModuleRecord({
            implementation: module1,
            codeHash: bytes32(0),
            deployParamsHash: bytes32(0),
            schemaId: bytes32(0),
            sender: dev,
            data: abi.encode(moduleName)
        });

        vm.prank(makeAddr("AARegistry"));
        rsRegistrar.moduleRegistration(moduleMockRecord);

        address _module1 = ens.owner(LibNamehash.namehash("module1.rhinestone.eth"));
        assertEq(_module1, module1);
    }
}
