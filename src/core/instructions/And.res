// AND instruction - Bitwise AND with ancilla
// Operation: c = a AND b (requires c to be 0 initially)
// Inverse: c = 0 (clear c)
// This is reversible using Bennett's trick: we store the result in an ancilla

let make = (varA: string, varB: string, varC: string): Instruction.t => {
  instructionType: "AND",
  args: [varA, varB, varC],
  execute: state => {
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let valB = Js.Dict.get(state, varB)->Belt.Option.getWithDefault(0)
    // Bitwise AND: c = a & b
    let result = land(valA, valB)
    Js.Dict.set(state, varC, result)
  },
  invert: state => {
    // Inverse: clear the ancilla (set c to 0)
    // This assumes c was 0 before execute
    Js.Dict.set(state, varC, 0)
  },
}
