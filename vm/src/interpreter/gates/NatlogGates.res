// NatlogGates.res
// Natural logic domain gate implementations (stub - to be implemented)
// Future gates: logShift, entropyMap, rotE, muxE

open InterpreterTypes

// Placeholder noop gate
let noop = (_step: gateOp, state: state<natSymbol>): state<natSymbol> => state

// Gate registry - natlog gates to be implemented
let registry: Belt.Map.String.t<gateFn<natSymbol>> = {
  Belt.Map.String.empty->Belt.Map.String.set("noop", noop)
}

// Execute a gate by name
let execute = (opName: string, step: gateOp, state: state<natSymbol>): state<natSymbol> => {
  switch Belt.Map.String.get(registry, opName) {
  | None => Exn.raiseError("Unknown natlog gate: " ++ opName)
  | Some(gateFn) => gateFn(step, state)
  }
}
