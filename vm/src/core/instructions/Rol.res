// ROL instruction - Rotate Left
// Operation: a = (a << 1) | (a >> 31) for 32-bit integers
// Inverse: ROR (rotate right)

let make = (varA: string, ~bits: int=1, ()): Instruction.t => {
  instructionType: "ROL",
  args: [varA],
  execute: state => {
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    // Rotate left by 'bits' positions (32-bit)
    let rotated = lor(
      lsl(valA, bits),
      lsr(valA, 32 - bits)
    )
    Js.Dict.set(state, varA, rotated)
  },
  invert: state => {
    // Inverse: rotate right by same number of bits
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let rotated = lor(
      lsr(valA, bits),
      lsl(valA, 32 - bits)
    )
    Js.Dict.set(state, varA, rotated)
  },
}
