// ROR instruction - Rotate Right
// Operation: a = (a >> 1) | (a << 31) for 32-bit integers
// Inverse: ROL (rotate left)

let make = (varA: string, ~bits: int=1, ()): Instruction.t => {
  instructionType: "ROR",
  args: [varA],
  execute: state => {
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    // Rotate right by 'bits' positions (32-bit)
    let rotated = lor(
      lsr(valA, bits),
      lsl(valA, 32 - bits)
    )
    Js.Dict.set(state, varA, rotated)
  },
  invert: state => {
    // Inverse: rotate left by same number of bits
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let rotated = lor(
      lsl(valA, bits),
      lsr(valA, 32 - bits)
    )
    Js.Dict.set(state, varA, rotated)
  },
}
