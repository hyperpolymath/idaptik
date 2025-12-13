// InterpreterTypes.res
// Shared types for the reversible logic interpreter

// Allowed domains that a step or puzzle can specify
type logicDomain = Binary | Ternary | Natlog

// Value types for each logic family
type bit = Zero | One
type trit = T0 | T1 | T2
type natSymbol = int // Placeholder for more complex symbolic types

// A single logic step: can be atomic (e.g. flip) or recursive (e.g. seq)
type rec gateOp = {
  domain: option<logicDomain>,
  op: string,
  target: option<string>,
  targets: option<array<string>>,
  result: option<string>,
  steps: option<array<gateOp>>,
}

// The interpreter state maps variable names to their values
module BitState = Belt.Map.String
module TritState = Belt.Map.String
module NatlogState = Belt.Map.String

type state<'a> = Belt.Map.String.t<'a>

// Gate function signature
type gateFn<'a> = (gateOp, state<'a>) => state<'a>

// Bit operations
let bitToInt = (b: bit): int =>
  switch b {
  | Zero => 0
  | One => 1
  }

let intToBit = (i: int): bit =>
  switch i {
  | 0 => Zero
  | _ => One
  }

let xorBit = (a: bit, b: bit): bit =>
  switch (a, b) {
  | (Zero, Zero) | (One, One) => Zero
  | (Zero, One) | (One, Zero) => One
  }

let flipBit = (b: bit): bit =>
  switch b {
  | Zero => One
  | One => Zero
  }
