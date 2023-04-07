export type PrivateInputs = {
  sourceIdentifier: BigInt;
  sourceSecret: BigInt;
  sourceCommitmentReceipt: BigInt[];
  accountMerklePathElements: BigInt[];
  accountMerklePathIndices: number[];
  accountsTreeRoot: BigInt;
};

export type PublicInputs = {
  destinationIdentifier: BigInt;
  commitmentMapperPubKey: BigInt[];
  externalNullifier: BigInt;
  nullifier: BigInt;
};

export type Inputs = {
  privateInputs: PrivateInputs;
  publicInputs: PublicInputs;
};
