pragma circom 2.1.2;

include "../node_modules/circomlib/circuits/compconstant.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";

include "./common/verify-merkle-path.circom";
include "./common/verify-hydra-commitment.circom";

// This is the circuit for the Zkid Proving Scheme
// please read this doc to understand the underlying concepts
// we refer to code of sismo: https://hydra-s1.docs.sismo.io
template hydraS1(registryTreeHeight, accountsTreeHeight) {
  // Private inputs
  signal input sourceIdentifier;
  signal input sourceSecret; 
  signal input sourceCommitmentReceipt[3];
  signal input accountMerklePathElements[accountsTreeHeight];
  signal input accountMerklePathIndices[accountsTreeHeight];
  signal input accountsTreeRoot; // credential: bayc holders group -> merkle root

  // Public inputs
  signal input destinationIdentifier; // contract_address + tokenId (if new -> -1)
  signal input commitmentMapperPubKey[2];
  signal input externalNullifier; //
  signal input nullifier;

  // Verify the source account went through the Hydra Delegated Proof of Ownership
  // That means the user own the source address
  component sourceCommitmentVerification = VerifyHydraCommitment();
  sourceCommitmentVerification.address <== sourceIdentifier;
  sourceCommitmentVerification.secret <== sourceSecret; 
  sourceCommitmentVerification.commitmentMapperPubKey[0] <== commitmentMapperPubKey[0];
  sourceCommitmentVerification.commitmentMapperPubKey[1] <== commitmentMapperPubKey[1];
  sourceCommitmentVerification.commitmentReceipt[0] <== sourceCommitmentReceipt[0];
  sourceCommitmentVerification.commitmentReceipt[1] <== sourceCommitmentReceipt[1];
  sourceCommitmentVerification.commitmentReceipt[2] <== sourceCommitmentReceipt[2];

  // Verification that the source account is part of an accounts tree
  // Recreating the leaf which is the hash of an account identifier and an account value
  component accountLeafConstructor = Poseidon(2);
  accountLeafConstructor.inputs[0] <== sourceIdentifier;
  accountLeafConstructor.inputs[1] <== 1; // source value default 1

  // This tree is an Accounts Merkle Tree which is constituted by accounts
  // https://accounts-registry-tree.docs.sismo.io
  // leaf = Hash(accountIdentifier, accountValue) 
  // verify the merkle path
  component accountsTreesPathVerifier = VerifyMerklePath(accountsTreeHeight);
  accountsTreesPathVerifier.leaf <== accountLeafConstructor.out;  
  accountsTreesPathVerifier.root <== accountsTreeRoot;
  for (var i = 0; i < accountsTreeHeight; i++) {
    accountsTreesPathVerifier.pathElements[i] <== accountMerklePathElements[i];
    accountsTreesPathVerifier.pathIndices[i] <== accountMerklePathIndices[i];
  }

  // Verify the nullifier is valid
  // compute the sourceSecretHash using the hash of the sourceSecret
  signal sourceSecretHash; 
  component sourceSecretHasher = Poseidon(2);
  sourceSecretHasher.inputs[0] <== sourceSecret;
  sourceSecretHasher.inputs[1] <== 1;  
  sourceSecretHash <== sourceSecretHasher.out; 

  // Verify the nullifier is valid
  // by hashing the sourceSecretHash and externalNullifier
  // and verifying the result is equals
  component nullifierHasher = Poseidon(2);
  nullifierHasher.inputs[0] <== sourceSecretHash;
  nullifierHasher.inputs[1] <== externalNullifier; // can be credentialId
  nullifierHasher.out === nullifier;

  signal destinationIdentifierSquared;
  destinationIdentifierSquared <== destinationIdentifier * destinationIdentifier;
}

component main {public [commitmentMapperPubKey, externalNullifier, nullifier, destinationIdentifier]} = hydraS1(20,20);