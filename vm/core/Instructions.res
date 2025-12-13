// Instructions.res
// Core reversible instructions for the VM

open Instruction
open State

// ADD: state[a] += state[b]
// Inverse: state[a] -= state[b]
let makeAdd = (a: string, b: string): instruction => {
  {
    instructionType: "ADD",
    args: [a, b],
    execute: state => {
      switch (get(state, a), get(state, b)) {
      | (Some(valA), Some(valB)) => set(state, a, valA + valB)
      | _ => state
      }
    },
    invert: state => {
      switch (get(state, a), get(state, b)) {
      | (Some(valA), Some(valB)) => set(state, a, valA - valB)
      | _ => state
      }
    },
  }
}

// SUB: state[a] -= state[b]
// Inverse: state[a] += state[b]
let makeSub = (a: string, b: string): instruction => {
  {
    instructionType: "SUB",
    args: [a, b],
    execute: state => {
      switch (get(state, a), get(state, b)) {
      | (Some(valA), Some(valB)) => set(state, a, valA - valB)
      | _ => state
      }
    },
    invert: state => {
      switch (get(state, a), get(state, b)) {
      | (Some(valA), Some(valB)) => set(state, a, valA + valB)
      | _ => state
      }
    },
  }
}

// NEGATE: state[a] = -state[a]
// Inverse: same operation (self-inverse)
let makeNegate = (a: string): instruction => {
  let negate = state => {
    switch get(state, a) {
    | Some(val) => set(state, a, -val)
    | None => state
    }
  }
  {
    instructionType: "NEGATE",
    args: [a],
    execute: negate,
    invert: negate, // Self-inverse
  }
}

// SWAP: swap state[a] and state[b]
// Inverse: same operation (self-inverse)
let makeSwap = (a: string, b: string): instruction => {
  let swap = state => {
    switch (get(state, a), get(state, b)) {
    | (Some(valA), Some(valB)) => state->set(a, valB)->set(b, valA)
    | _ => state
    }
  }
  {
    instructionType: "SWAP",
    args: [a, b],
    execute: swap,
    invert: swap, // Self-inverse
  }
}

// NOOP: do nothing
// Inverse: do nothing
let makeNoop = (): instruction => {
  let noop = state => state
  {
    instructionType: "NOOP",
    args: [],
    execute: noop,
    invert: noop,
  }
}

// MUL: state[a] *= state[b] (only reversible if state[b] != 0)
let makeMul = (a: string, b: string): instruction => {
  {
    instructionType: "MUL",
    args: [a, b],
    execute: state => {
      switch (get(state, a), get(state, b)) {
      | (Some(valA), Some(valB)) => set(state, a, valA * valB)
      | _ => state
      }
    },
    invert: state => {
      switch (get(state, a), get(state, b)) {
      | (Some(valA), Some(valB)) if valB != 0 => set(state, a, valA / valB)
      | _ => state
      }
    },
  }
}

// XOR: state[a] ^= state[b]
// Inverse: same operation (self-inverse)
let makeXor = (a: string, b: string): instruction => {
  let xor = state => {
    switch (get(state, a), get(state, b)) {
    | (Some(valA), Some(valB)) => set(state, a, lxor(valA, valB))
    | _ => state
    }
  }
  {
    instructionType: "XOR",
    args: [a, b],
    execute: xor,
    invert: xor, // Self-inverse
  }
}

// ROT: rotate left by n bits (for 32-bit integers)
let makeRotLeft = (a: string, n: int): instruction => {
  {
    instructionType: "ROT_LEFT",
    args: [a, Belt.Int.toString(n)],
    execute: state => {
      switch get(state, a) {
      | Some(val) =>
        let shifted = lor(lsl(val, n), lsr(val, 32 - n))
        set(state, a, shifted)
      | None => state
      }
    },
    invert: state => {
      switch get(state, a) {
      | Some(val) =>
        let shifted = lor(lsr(val, n), lsl(val, 32 - n))
        set(state, a, shifted)
      | None => state
      }
    },
  }
}
