// Instruction.res
// Core instruction type for the reversible VM

type state = Belt.Map.String.t<int>

// Instruction interface implemented as a module type
module type InstructionType = {
  let instructionType: string
  let args: array<string>
  let execute: state => state
  let invert: state => state
}

// Generic instruction record for runtime use
type instruction = {
  instructionType: string,
  args: array<string>,
  execute: state => state,
  invert: state => state,
}
