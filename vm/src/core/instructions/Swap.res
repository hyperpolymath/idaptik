// SWAP instruction - swaps values of two registers

let make = (a: string, b: string): Instruction.t => {
  let swapFn = state => {
    let valA = Js.Dict.get(state, a)->Belt.Option.getWithDefault(0)
    let valB = Js.Dict.get(state, b)->Belt.Option.getWithDefault(0)
    Js.Dict.set(state, a, valB)
    Js.Dict.set(state, b, valA)
  }

  {
    instructionType: "SWAP",
    args: [a, b],
    execute: swapFn,
    invert: swapFn, // swap is its own inverse
  }
}
