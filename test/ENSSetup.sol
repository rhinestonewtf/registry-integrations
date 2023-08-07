// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import { ENSRegistry } from "ens-contracts/registry/ENSRegistry.sol";
import { ModuleRegistrar} from "../src/ENSIntegration/ModuleRegistrar.sol";
import { BaseRegistrarImplementation } from
    "ens-contracts/ethregistrar/BaseRegistrarImplementation.sol";
import { LibNamehash } from "../src/ENSIntegration/LibNamehash.sol";

/// @title ENSBaseTest
/// @author zeroknots
contract ENSBaseTest is Test {
    ENSRegistry ens;
    BaseRegistrarImplementation registrar;

    ModuleRegistrar rsRegistrar;

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
        rsRegistrar = new ModuleRegistrar(ens, rhinestoneNode);

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
        rsRegistrar.register(label, module1);

        address _module1 = ens.owner(LibNamehash.namehash("module1.rhinestone.eth"));
        assertEq(_module1, module1);
    }
}
