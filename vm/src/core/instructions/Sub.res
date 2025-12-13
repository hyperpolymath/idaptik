// SUB instruction - subtracts value of register b from register a

let make = (a: string, b: string): Instruction.t => {
  instructionType: "SUB",
  args: [a, b],
  execute: state => {
    let valA = Js.Dict.get(state, a)->Belt.Option.getWithDefault(0)
    let valB = Js.Dict.get(state, b)->Belt.Option.getWithDefault(0)
    Js.Dict.set(state, a, valA - valB)
  },
  invert: state => {
    let valA = Js.Dict.get(state, a)->Belt.Option.getWithDefault(0)
    let valB = Js.Dict.get(state, b)->Belt.Option.getWithDefault(0)
    Js.Dict.set(state, a, valA + valB)
  },
}
