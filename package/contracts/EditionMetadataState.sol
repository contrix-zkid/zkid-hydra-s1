// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

  struct Attribute {
    string name;
    string value;
  }

contract EditionMetadataState {
  string public description;
  string public imageUrl;
  string public externalUrl;

  mapping(uint256 => Attribute[]) public properties;
}
