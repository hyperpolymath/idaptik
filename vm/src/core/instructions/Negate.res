// NEGATE instruction - negates value of a register

let make = (a: string): Instruction.t => {
  let negateFn = state => {
    let valA = Js.Dict.get(state, a)->Belt.Option.getWithDefault(0)
    Js.Dict.set(state, a, -valA)
  }

  {
    instructionType: "NEGATE",
    args: [a],
    execute: negateFn,
    invert: negateFn, // negating again undoes it
  }
}
