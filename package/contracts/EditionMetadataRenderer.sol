// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import {Base64} from "./utils/Base64.sol";
import {LibString} from "./utils/LibString.sol";
import "./EditionMetadataState.sol";

/// logic for rendering metadata associated with editions
contract EditionMetadataRenderer is EditionMetadataState {

  /// Generate edition metadata from storage information as base64-json blob
  /// Combines the media data and metadata
  /// @param name Name of NFT in metadata
  /// @param tokenId Token ID for specific token
  /// @param editionSize Size of entire edition to show
  function createTokenMetadata(
    string memory name,
    uint256 tokenId,
    uint256 editionSize
  ) internal view returns (string memory) {

    string memory editionSizeText = editionSize > 0 ?
    string.concat("/", LibString.toString(editionSize)) : "";

    string memory nameText = string.concat(
      '"name":"', LibString.escapeJSON(name), " #",
      LibString.toString(tokenId), editionSizeText, '",');

    string memory descriptionText = string.concat(
      '"description":"', LibString.escapeJSON(description), '",');

    string memory externalURLText = bytes(externalUrl).length > 0 ?
    string.concat('"external_url":"', externalUrl, '",') : "";

    string memory imageUrlText = bytes(imageUrl).length > 0 ?
    string.concat('"image":"', imageUrl, '",') : "";

    return toBase64DataUrl(string.concat('{',
      nameText,
      descriptionText,
      externalURLText,
      imageUrlText,
      getPropertiesJson(tokenId),
      "}")
    );
  }

  /// Encodes contract level metadata into base64-data url format
  /// @dev see https://docs.opensea.io/docs/contract-level-metadata
  /// @dev borrowed from https://github.com/ourzora/zora-drops-contracts/blob/main/src/utils/NFTMetadataRenderer.sol
  function createContractMetadata(
    string memory name,
    uint256 royaltyBPS,
    address royaltyRecipient
  ) internal view returns (string memory) {

    string memory nameText = string.concat(
      '"name":"', LibString.escapeJSON(name), '",');

    string memory descriptionText = string.concat(
      '"description":"', LibString.escapeJSON(description), '",');

    string memory royaltyText = string.concat(
      '"seller_fee_basis_points":"', LibString.toString(royaltyBPS), '",');

    string memory royaltyRecipientText = string.concat(
      '"fee_recipient":"', LibString.toHexString(royaltyRecipient), '",');

    string memory externalURLText = bytes(externalUrl).length > 0 ?
    string.concat('"external_link":"', externalUrl, '",') : "";

    string memory imageUrlText = bytes(imageUrl).length > 0 ?
    string.concat('"image":"', imageUrl, '",') : "";

    return toBase64DataUrl(string.concat('{',
      nameText,
      descriptionText,
      royaltyText,
      royaltyRecipientText,
      externalURLText,
      imageUrlText,
      "}")
    );
  }

  /// Encodes the argument json bytes into base64-data uri format
  /// @param json Raw json to base64 and turn into a data-uri
  function toBase64DataUrl(string memory json)
  internal
  pure
  returns (string memory)
  {
    return string.concat(
      "data:application/json;base64,",
      Base64.encode(bytes(json))
    );
  }

  /// Produces Enjin Metadata style simple properties
  /// @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md#erc-1155-metadata-uri-json-schema
  function getPropertiesJson(uint256 tokenId) internal view returns (string memory) {
    return string.concat('"properties":{', calcPropertiesJson(tokenId), "}");
  }

  function calcPropertiesJson(uint256 tokenId) virtual internal view returns (string memory) {
    Attribute[] memory attrs = properties[tokenId];

    uint256 length = attrs.length;
    if (length == 0) return '';

    string memory buffer = '';

  unchecked {
    // `length - 1` can not underflow because of the `length == 0` check above
    uint256 lengthMinusOne = length - 1;

    for (uint256 i = 0; i < lengthMinusOne; ) {
      buffer = string.concat(
        buffer,
        stringifyStringAttribute(attrs[i].name, attrs[i].value),
        ","
      );

      // counter increment can not overflow
      ++i;
    }

    // add the last attribute without a trailing comma
    Attribute memory lastAttr = attrs[lengthMinusOne];
    return string.concat(
      buffer,
      stringifyStringAttribute(lastAttr.name, lastAttr.value)
    );
  }
  }

  function stringifyStringAttribute(string memory name, string memory value)
  internal
  pure
  returns (string memory)
  {
    // let's only escape the value, property names should not be using any special characters
    return
    string.concat('"', name, '":"', LibString.escapeJSON(value), '"');
  }

  //  function setProperties(string[] calldata names, uint256 tokenId, string[] calldata values) public override onlyOwner {
  //    uint256 length = names.length;
  //    if (values.length != length) {
  //      revert LengthMismatch();
  //    }
  //
  //    propertyNames = names;
  //    for (uint256 i = 0; i < length;) {
  //      string calldata name = names[i];
  //      string calldata value = values[i];
  //      if (bytes(name).length == 0 || bytes(value).length == 0) {
  //        revert BadAttribute(name, value);
  //      }
  //
  //      emit PropertyUpdated(name, properties[name][tokenId], value);
  //
  //      properties[name][tokenId] = value;
  //
  //    unchecked {
  //      ++i;
  //    }
  //    }
  //  }
}
