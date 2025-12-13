// BinaryGates.res
// Binary domain gate implementations for reversible logic

open InterpreterTypes

// Flip a single bit
let flip = (step: gateOp, state: state<bit>): state<bit> => {
  switch step.target {
  | None => Exn.raiseError("Missing target for flip")
  | Some(target) =>
    switch Belt.Map.String.get(state, target) {
    | None => Exn.raiseError("Target not found in state: " ++ target)
    | Some(value) => Belt.Map.String.set(state, target, flipBit(value))
    }
  }
}

// Swap two bits
let swap = (step: gateOp, state: state<bit>): state<bit> => {
  switch step.targets {
  | None => Exn.raiseError("Missing targets for swap")
  | Some(targets) =>
    switch (Belt.Array.get(targets, 0), Belt.Array.get(targets, 1)) {
    | (Some(a), Some(b)) =>
      switch (Belt.Map.String.get(state, a), Belt.Map.String.get(state, b)) {
      | (Some(valA), Some(valB)) =>
        state
        ->Belt.Map.String.set(a, valB)
        ->Belt.Map.String.set(b, valA)
      | _ => Exn.raiseError("Targets not found in state")
      }
    | _ => Exn.raiseError("Swap requires exactly 2 targets")
    }
  }
}

// XOR two bits into result
let xor = (step: gateOp, state: state<bit>): state<bit> => {
  switch (step.targets, step.result) {
  | (Some(targets), Some(result)) =>
    switch (Belt.Array.get(targets, 0), Belt.Array.get(targets, 1)) {
    | (Some(a), Some(b)) =>
      switch (Belt.Map.String.get(state, a), Belt.Map.String.get(state, b)) {
      | (Some(valA), Some(valB)) =>
        Belt.Map.String.set(state, result, xorBit(valA, valB))
      | _ => Exn.raiseError("XOR targets not found in state")
      }
    | _ => Exn.raiseError("XOR requires exactly 2 targets")
    }
  | _ => Exn.raiseError("XOR requires targets and result")
  }
}

// Gate registry
let registry: Belt.Map.String.t<gateFn<bit>> = {
  open Belt.Map.String
  empty
  ->set("flip", flip)
  ->set("swap", swap)
  ->set("xor", xor)
}

// Execute a gate by name
let execute = (opName: string, step: gateOp, state: state<bit>): state<bit> => {
  switch Belt.Map.String.get(registry, opName) {
  | None => Exn.raiseError("Unknown binary gate: " ++ opName)
  | Some(gateFn) => gateFn(step, state)
  }
}
