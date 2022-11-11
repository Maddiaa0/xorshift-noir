import { compile } from "@noir-lang/noir_wasm";
import {
  setup_generic_prover_and_verifier,
  create_proof,
  verify_proof,
  StandardExampleProver,
  StandardExampleVerifier,
} from "@noir-lang/barretenberg/dest/client_proofs";

import { resolve } from "path";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { BarretenbergWasm } from "@noir-lang/barretenberg/dest/wasm";
import { SinglePedersen } from "@noir-lang/barretenberg/dest/crypto";

let barrentenberg: BarretenbergWasm;
let pedersen: SinglePedersen;

/// Typescript reference implementation of randomness function
class TsXorShift {
  public next: BigNumber;

  // Seed is going to be a relatively small input
  constructor(seed: number) {
    let n = pedersen.hashToField(Buffer.from([seed]));
    let a = BigNumber.from(n);
    this.next = a.mask(32);
  }

  getU32(): BigNumber {
    let x = this.next;
    let a = x.shl(13);
    x = x.xor(a).mask(32);
    let b = x.shr(17);
    x = x.xor(b).mask(32);
    let c = x.shl(5);
    x = x.xor(c).mask(32);
    this.next = x.mask(32);
    return x;
  }
}

describe("Test Rand generator ts", () => {
  let acir: any;
  let prover: StandardExampleProver;
  let verifier: StandardExampleVerifier;

  // arbitrary setup, create a prover and verifier we can use in our tests
  before(async () => {
    barrentenberg = await BarretenbergWasm.new();
    await barrentenberg.init();
    pedersen = new SinglePedersen(barrentenberg);

    const compiled = compile(resolve(__dirname, "../circuits/src/main.nr"));
    const acir = compiled.circuit;
    let [p, v] = await setup_generic_prover_and_verifier(acir);
    prover = p;
    verifier = v;
  });

  it("The snark version should verify the random number generation for the same seed u32", async () => {
    let seed = 0x1;
    let rand = new TsXorShift(seed);
    let generatedArr: BigNumber[] = [];
    for (let i = 0; i < 5; i++) {
      generatedArr.push(rand.getU32());
    }
    console.log(generatedArr.map((i) => i.toHexString()));
    let abi = {
      seed,
      return: generatedArr.map((i) => i.toHexString()),
    };

    const compiled = compile(resolve(__dirname, "../circuits/src/main.nr"));
    const acir = compiled.circuit;

    const proof = await create_proof(prover, acir, abi);
    const verified = await verify_proof(verifier, proof);

    expect(verified).eq(true);
  });
});
