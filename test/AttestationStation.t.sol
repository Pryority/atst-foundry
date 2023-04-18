// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AttestationStation.sol";

contract AttestationStationTest is Test {
    AttestationStation atst;
    mapping(address => mapping(address => mapping(bytes32 => AttestationStation.AttestationData)))
        public attestations;
    address owner;

    function setUp() public {
        atst = new AttestationStation();
        owner = msg.sender;
    }

    function testAttest() public {
        vm.startPrank(owner);
        address about = 0x0000000000000000000000000000000000000000;
        bytes32 key = 0x746573742e6b65792e3100000000000000000000000000000000000000000000;
        bytes memory val = hex"01";
        atst.attest(about, key, val);
        AttestationStation.AttestationData memory attestation = attestations[
            owner
        ][about][key];
        bytes memory storedVal = atst.attestations(owner, about, key);
        assertEq(storedVal, val, "Attestation value not stored correctly");
        assertEq(
            attestation.about,
            0x0000000000000000000000000000000000000000,
            "About address mismatch"
        );
        vm.stopPrank();
    }

    function testFailAttest() public {
        bool isCorrectAttestation;
        vm.startPrank(owner);
        address about = 0x0000000000000000000000000000000000000000;
        bytes32 key = 0x746573742e6b65792e3100000000000000000000000000000000000000000000;
        bytes memory val = hex"01";
        atst.attest(about, key, val);
        AttestationStation.AttestationData memory attestation = attestations[
            owner
        ][about][key];
        bytes memory storedVal = atst.attestations(owner, about, key);

        assertEq(storedVal, val, "Attestation value not stored correctly");
        assertEq(
            attestation.about,
            0x0000000000000000000000000000000000000000,
            "About address mismatch"
        );
        // Store the attestation key in the boolean variable
        isCorrectAttestation =
            attestation.key ==
            0x0000000000000000000000000000000000000000000000000000000000000000;
        // Assert that the stored attestation key is not the correct one
        assertFalse(isCorrectAttestation, "Attestation key stored correctly");
        vm.stopPrank();
    }

    function testAttestMultiple() public {
        vm.startPrank(owner);
        AttestationStation.AttestationData[]
            memory _attestations = new AttestationStation.AttestationData[](2);
        address about1 = 0x0000000000000000000000000000000000000001;
        bytes32 key1 = 0x746573742e6b65792e3100000000000000000000000000000000000000000001;
        bytes memory val1 = hex"01";
        _attestations[0] = AttestationStation.AttestationData(
            about1,
            key1,
            val1
        );

        address about2 = 0x0000000000000000000000000000000000000002;
        bytes32 key2 = 0x746573742e6b65792e3100000000000000000000000000000000000000000002;
        bytes memory val2 = hex"02";
        _attestations[1] = AttestationStation.AttestationData(
            about2,
            key2,
            val2
        );

        atst.attestMultiple(_attestations);

        bytes memory storedVal1 = atst.attestations(owner, about1, key1);
        bytes memory storedVal2 = atst.attestations(owner, about2, key2);

        assertEq(storedVal1, val1, "Attestation 1 value not stored correctly");
        assertEq(storedVal2, val2, "Attestation 2 value not stored correctly");
        vm.stopPrank();
    }

    function testGetAttestations() public {
        vm.startPrank(owner);
        address about = 0x0000000000000000000000000000000000000000;
        bytes32 key1 = 0x746573742e6b65792e3100000000000000000000000000000000000000000000;
        bytes memory val1 = hex"01";
        bytes32 key2 = 0x746573742e6b65792e3200000000000000000000000000000000000000000000;
        bytes memory val2 = hex"02";
        atst.attest(about, key1, val1);
        atst.attest(about, key2, val2);
        AttestationStation.AttestationData[] memory attestationDataList = atst
            .getAttestations(about);
        assertEq(
            attestationDataList.length,
            2,
            "Incorrect number of attestations retrieved"
        );
        assertEq(attestationDataList[0].about, about, "About address mismatch");
        assertEq(attestationDataList[0].key, key1, "Key mismatch");
        assertEq(attestationDataList[0].val, val1, "Value mismatch");
        assertEq(attestationDataList[1].about, about, "About address mismatch");
        assertEq(attestationDataList[1].key, key2, "Key mismatch");
        assertEq(attestationDataList[1].val, val2, "Value mismatch");
        vm.stopPrank();
    }
}
