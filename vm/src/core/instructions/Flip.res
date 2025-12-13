// FLIP instruction - Bitwise NOT
// Operation: a = NOT a
// Inverse: NOT a again (self-inverse)

let make = (varA: string): Instruction.t => {
  instructionType: "FLIP",
  args: [varA],
  execute: state => {
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    // Bitwise NOT: ~a
    // For integers, we'll use a simple inversion for demonstration
    // In a real binary system, this would flip all bits
    let result = lnot(valA)
    Js.Dict.set(state, varA, result)
  },
  invert: state => {
    // FLIP is self-inverse: NOT(NOT(a)) = a
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let result = lnot(valA)
    Js.Dict.set(state, varA, result)
  },
}
