// Unit tests for XOR instruction

open Belt

let testXorBasic = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 0b1100)  // 12 in binary
  Js.Dict.set(state, "b", 0b1010)  // 10 in binary

  let instr = Xor.make("a", "b")
  instr.execute(state)

  // 1100 XOR 1010 = 0110 = 6
  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 0b0110
}

let testXorSelfInverse = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 42)
  Js.Dict.set(state, "b", 17)

  let instr = Xor.make("a", "b")
  instr.execute(state)
  instr.execute(state)  // XOR twice with same value = identity

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 42
}

let testXorZero = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 42)
  Js.Dict.set(state, "b", 0)

  let instr = Xor.make("a", "b")
  instr.execute(state)

  // n XOR 0 = n
  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 42
}

let testXorReversibility = (): bool => {
  let testCases = [(42, 17), (255, 128), (0, 0), (1, 1)]

  Array.every(testCases, ((a, b)) => {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", a)
    Js.Dict.set(state, "y", b)

    let original = State.cloneState(state)
    let instr = Xor.make("x", "y")

    instr.execute(state)
    instr.invert(state)

    State.statesMatch(state, original)
  })
}

let runAll = (): unit => {
  Js.Console.log("[XOR Tests]")

  Js.Console.log(testXorBasic() ? "  ✓ Basic XOR" : "  ✗ Basic XOR FAILED")
  Js.Console.log(testXorSelfInverse() ? "  ✓ Self-inverse property" : "  ✗ Self-inverse FAILED")
  Js.Console.log(testXorZero() ? "  ✓ XOR with zero" : "  ✗ XOR with zero FAILED")
  Js.Console.log(testXorReversibility() ? "  ✓ Reversibility property" : "  ✗ Reversibility FAILED")
}
