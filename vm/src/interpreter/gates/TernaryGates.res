// TernaryGates.res
// Ternary domain gate implementations (stub - to be implemented)

open InterpreterTypes

// Placeholder noop gate
let noop = (_step: gateOp, state: state<trit>): state<trit> => state

// Gate registry - ternary gates to be implemented
let registry: Belt.Map.String.t<gateFn<trit>> = {
  Belt.Map.String.empty->Belt.Map.String.set("noop", noop)
}

// Execute a gate by name
let execute = (opName: string, step: gateOp, state: state<trit>): state<trit> => {
  switch Belt.Map.String.get(registry, opName) {
  | None => Exn.raiseError("Unknown ternary gate: " ++ opName)
  | Some(gateFn) => gateFn(step, state)
  }
}
