// ReversibleVM.res
// Core reversible virtual machine

open Instruction
open State

type vm = {
  mutable state: state,
  mutable history: array<instruction>,
}

// Create a new VM with initial state
let make = (initial: state): vm => {
  {state: cloneState(initial), history: []}
}

// Run an instruction forward
let run = (vm: vm, instr: instruction): unit => {
  vm.state = instr.execute(vm.state)
  vm.history = Belt.Array.concat(vm.history, [instr])
}

// Undo the last instruction
let undo = (vm: vm): unit => {
  let len = Belt.Array.length(vm.history)
  if len > 0 {
    switch Belt.Array.get(vm.history, len - 1) {
    | None => ()
    | Some(instr) =>
      vm.state = instr.invert(vm.state)
      vm.history = Belt.Array.slice(vm.history, ~offset=0, ~len=len - 1)
    }
  }
}

// Get current state
let getState = (vm: vm): state => vm.state

// Get history length
let historyLength = (vm: vm): int => Belt.Array.length(vm.history)

// Run a sequence of instructions
let runAll = (vm: vm, instructions: array<instruction>): unit => {
  Belt.Array.forEach(instructions, instr => run(vm, instr))
}

// Undo all instructions
let undoAll = (vm: vm): unit => {
  while historyLength(vm) > 0 {
    undo(vm)
  }
}
