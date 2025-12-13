// NOOP instruction - no operation (does nothing)

let make = (): Instruction.t => {
  instructionType: "NOOP",
  args: [],
  execute: _state => (),
  invert: _state => (),
}
