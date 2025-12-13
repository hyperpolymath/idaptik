// Unit tests for ADD instruction

open Belt

let testAddBasic = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 10)
  Js.Dict.set(state, "b", 5)

  let instr = Add.make("a", "b")
  instr.execute(state)

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 15
}

let testAddInverse = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 10)
  Js.Dict.set(state, "b", 5)

  let instr = Add.make("a", "b")
  instr.execute(state)
  instr.invert(state)

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 10
}

let testAddNegative = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", -10)
  Js.Dict.set(state, "b", 5)

  let instr = Add.make("a", "b")
  instr.execute(state)

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == -5
}

let testAddZero = (): bool => {
  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 42)
  Js.Dict.set(state, "b", 0)

  let instr = Add.make("a", "b")
  instr.execute(state)

  Js.Dict.get(state, "a")->Option.getWithDefault(0) == 42
}

// Property-based test: reversibility
let testAddReversibility = (): bool => {
  let testCases = [
    (10, 5),
    (-10, 5),
    (10, -5),
    (0, 0),
    (100, -100),
    (999, 1),
  ]

  Array.every(testCases, ((a, b)) => {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", a)
    Js.Dict.set(state, "y", b)

    let original = State.cloneState(state)
    let instr = Add.make("x", "y")

    instr.execute(state)
    instr.invert(state)

    State.statesMatch(state, original)
  })
}

let runAll = (): unit => {
  Js.Console.log("[ADD Tests]")

  Js.Console.log(testAddBasic() ? "  ✓ Basic addition" : "  ✗ Basic addition FAILED")
  Js.Console.log(testAddInverse() ? "  ✓ Inverse operation" : "  ✗ Inverse operation FAILED")
  Js.Console.log(testAddNegative() ? "  ✓ Negative numbers" : "  ✗ Negative numbers FAILED")
  Js.Console.log(testAddZero() ? "  ✓ Adding zero" : "  ✗ Adding zero FAILED")
  Js.Console.log(testAddReversibility() ? "  ✓ Reversibility property" : "  ✗ Reversibility FAILED")
}
