#!/bin/bash -e
rm -rf artifacts
rm -rf cache
rm -rf node_modules
rm -rf types

rm -rf ./package/node_modules
rm -rf ./package/lib
rm -rf ./package/types
# Uncomment next lines to update Trusted setup
# rm -rf ./package/contracts/HydraS1Verifier.sol
# rm -rf ./package/src/prover/hydra-s1.wasm
# rm -rf ./package/src/prover/hydra-s1.zkey
# rm -rf ./package/src/verifier/hydra-s1-verification-key.json