// Reversible Virtual Machine

type t = {
  mutable state: Js.Dict.t<int>,
  mutable history: array<Instruction.t>,
}

// Create a new VM with initial state
let make = (initial: Js.Dict.t<int>): t => {
  state: State.cloneState(initial),
  history: [],
}

// Run an instruction (forward execution)
let run = (vm: t, instr: Instruction.t): unit => {
  instr.execute(vm.state)
  vm.history = Belt.Array.concat(vm.history, [instr])
}

// Undo the last instruction (reverse execution)
let undo = (vm: t): option<Instruction.t> => {
  let len = Belt.Array.length(vm.history)
  if len > 0 {
    let lastInstr = Belt.Array.getExn(vm.history, len - 1)
    lastInstr.invert(vm.state)
    vm.history = Belt.Array.slice(vm.history, ~offset=0, ~len=len - 1)
    Some(lastInstr)
  } else {
    None
  }
}

// Print current state to console
let printState = (vm: t): unit => {
  Js.log2("Current State:", vm.state)
}

// Get current state (immutable copy)
let getState = (vm: t): Js.Dict.t<int> => {
  State.cloneState(vm.state)
}

// Reset VM to a specific state
let resetState = (vm: t, newState: Js.Dict.t<int>): unit => {
  vm.state = State.cloneState(newState)
  vm.history = []
}

// Get history length
let historyLength = (vm: t): int => {
  Belt.Array.length(vm.history)
}
