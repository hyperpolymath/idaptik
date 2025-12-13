// Unit tests for SWAP instruction

open Belt

let testSwapBasic = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 10)
  Js.Dict.set(state, "b", 20)

  let instr = Swap.make("a", "b")
  instr.execute(state)

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 20 &&
  Js.Dict.get(state, "b")->Option.getWithDefault(0) == 10
}

let testSwapSelfInverse = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 10)
  Js.Dict.set(state, "b", 20)

  let instr = Swap.make("a", "b")
  instr.execute(state)
  instr.execute(state)  // Swap twice = identity

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 10 &&
  Js.Dict.get(state, "b")->Option.getWithDefault(0) == 20
}

let testSwapNegative = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", -5)
  Js.Dict.set(state, "b", 15)

  let instr = Swap.make("a", "b")
  instr.execute(state)

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 15 &&
  Js.Dict.get(state, "b")->Option.getWithDefault(0) == -5
}

let testSwapReversibility = (): bool => {
  let testCases = [(10, 20), (-5, 5), (0, 100), (42, -42)]

  Array.every(testCases, ((a, b)) => {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", a)
    Js.Dict.set(state, "y", b)

    let original = State.cloneState(state)
    let instr = Swap.make("x", "y")

    instr.execute(state)
    instr.invert(state)

    State.statesMatch(state, original)
  })
}

let runAll = (): unit => {
  Js.Console.log("[SWAP Tests]")

  Js.Console.log(testSwapBasic() ? "  ✓ Basic swap" : "  ✗ Basic swap FAILED")
  Js.Console.log(testSwapSelfInverse() ? "  ✓ Self-inverse property" : "  ✗ Self-inverse FAILED")
  Js.Console.log(testSwapNegative() ? "  ✓ Negative numbers" : "  ✗ Negative numbers FAILED")
  Js.Console.log(testSwapReversibility() ? "  ✓ Reversibility property" : "  ✗ Reversibility FAILED")
}
