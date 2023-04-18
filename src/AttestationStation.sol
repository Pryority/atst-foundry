// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Semver.sol";

/**
 * @title AttestationStation
 * @author Optimism Collective
 * @author Gitcoin
 * @notice Where attestations live.
 */
contract AttestationStation is Semver {
    /**
     * @notice Struct representing data that is being attested.
     *
     * @custom:field about Address for which the attestation is about.
     * @custom:field key   A bytes32 key for the attestation.
     * @custom:field val   The attestation as arbitrary bytes.
     */
    struct AttestationData {
        address about;
        bytes32 key;
        bytes val;
    }

    /**
     * @notice Maps addresses to attestations. Creator => About => Key => Value.
     */
    mapping(address => mapping(address => mapping(bytes32 => bytes)))
        public attestations;

    /**
     * @notice Maps addresses to all their keys. Creator => Keys[]
     */
    mapping(address => bytes32[]) private keysList;

    /**
     * @notice Emitted when Attestation is created.
     *
     * @param creator Address that made the attestation.
     * @param about   Address attestation is about.
     * @param key     Key of the attestation.
     * @param val     Value of the attestation.
     */
    event AttestationCreated(
        address indexed creator,
        address indexed about,
        bytes32 indexed key,
        bytes val
    );

    /**
     * @custom:semver 1.1.0
     */
    constructor() Semver(1, 1, 0) {}

    /**
     * @notice Allows anyone to create an attestation.
     *
     * @param _about Address that the attestation is about.
     * @param _key   A key used to namespace the attestation.
     * @param _val   An arbitrary value stored as part of the attestation.
     */
    // function attest(address _about, bytes32 _key, bytes memory _val) public {
    //     attestations[msg.sender][_about][_key] = _val;

    //     emit AttestationCreated(msg.sender, _about, _key, _val);
    // }

    function attest(address _about, bytes32 _key, bytes memory _val) public {
        attestations[msg.sender][_about][_key] = _val;

        // Add the key to the keyList for the about address
        if (attestations[msg.sender][_about][_key].length > 0) {
            bytes32[] storage keyList = keysList[_about];
            bool keyExists = false;
            for (uint256 i = 0; i < keyList.length; i++) {
                if (keyList[i] == _key) {
                    keyExists = true;
                    break;
                }
            }
            if (!keyExists) {
                keyList.push(_key);
            }
        }

        emit AttestationCreated(msg.sender, _about, _key, _val);
    }

    /**
     * @notice Allows anyone to create attestations.
     *
     * @param _attestations An array of attestation data.
     */
    function attestMultiple(AttestationData[] calldata _attestations) external {
        uint256 length = _attestations.length;
        for (uint256 i = 0; i < length; ) {
            AttestationData memory attestation = _attestations[i];

            attest(attestation.about, attestation.key, attestation.val);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Retrieves all attestations associated with a particular address.
     *
     * @param _about The address for which to retrieve attestations.
     * @return A dynamic array of AttestationData containing all attestations associated with the specified address.
     */
    function getAttestations(
        address _about
    ) public view returns (AttestationData[] memory) {
        AttestationData[] memory attestationDataList;
        uint256 numAttestations = 0;
        mapping(bytes32 => bytes) storage attestationsForAbout = attestations[
            msg.sender
        ][_about];

        // Count the number of attestations for the specified address
        bytes32[] memory keys = getKeysForAddress(_about);
        for (uint256 i = 0; i < keys.length; i++) {
            bytes32 key = keys[i];
            numAttestations += attestationsForAbout[key].length > 0 ? 1 : 0;
        }

        // Initialize the attestationDataList with the correct size
        attestationDataList = new AttestationData[](numAttestations);
        numAttestations = 0;

        // Retrieve the attestations for the specified address
        for (uint256 i = 0; i < keys.length; i++) {
            bytes32 key = keys[i];
            if (attestationsForAbout[key].length > 0) {
                attestationDataList[numAttestations].about = _about;
                attestationDataList[numAttestations].key = key;
                attestationDataList[numAttestations].val = attestationsForAbout[
                    key
                ];
                numAttestations++;
            }
        }

        return attestationDataList;
    }

    /**
     * @notice Retrieves all keys associated with a particular address.
     *
     * @param _about The address for which to retrieve keys.
     * @return A dynamic array of bytes32 containing all keys associated with the specified address.
     */
    function getKeysForAddress(
        address _about
    ) public view returns (bytes32[] memory) {
        return keysList[_about];
    }
}
