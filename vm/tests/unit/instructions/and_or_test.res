// Tests for AND and OR instructions (reversible with ancilla)

// Test AND instruction
let testAndReversibility = (): bool => {
  let testCases = [
    (0b1010, 0b1100, 0b1000), // AND result
    (0xFF, 0xFF, 0xFF),        // All ones
    (0xFF, 0x00, 0x00),        // Zero result
    (0b1111, 0b0101, 0b0101), // Mixed
  ]

  testCases->Belt.Array.every(((a, b, expected)) => {
    let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
    Js.Dict.set(state, "a", a)
    Js.Dict.set(state, "b", b)
    Js.Dict.set(state, "c", 0)  // Ancilla must be 0

    let original = State.cloneState(state)
    let instr = And.make("a", "b", "c")

    // Execute AND
    instr.execute(state)

    // Check result
    let c = Js.Dict.get(state, "c")->Belt.Option.getWithDefault(-1)
    let resultCorrect = c == expected

    // Invert (clear ancilla)
    instr.invert(state)

    // Should match original
    let reversible = State.statesMatch(state, original)

    resultCorrect && reversible
  })
}

// Test OR instruction
let testOrReversibility = (): bool => {
  let testCases = [
    (0b1010, 0b0101, 0b1111), // OR result
    (0xFF, 0xFF, 0xFF),        // All ones
    (0xFF, 0x00, 0xFF),        // One operand
    (0b1100, 0b0011, 0b1111), // Complementary
  ]

  testCases->Belt.Array.every(((a, b, expected)) => {
    let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
    Js.Dict.set(state, "a", a)
    Js.Dict.set(state, "b", b)
    Js.Dict.set(state, "c", 0)  // Ancilla must be 0

    let original = State.cloneState(state)
    let instr = Or.make("a", "b", "c")

    // Execute OR
    instr.execute(state)

    // Check result
    let c = Js.Dict.get(state, "c")->Belt.Option.getWithDefault(-1)
    let resultCorrect = c == expected

    // Invert (clear ancilla)
    instr.invert(state)

    // Should match original
    let reversible = State.statesMatch(state, original)

    resultCorrect && reversible
  })
}

// Test ancilla requirement
let testAncillaRequirement = (): bool => {
  // AND/OR require ancilla to be 0 for proper reversibility
  let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
  Js.Dict.set(state, "a", 0b1010)
  Js.Dict.set(state, "b", 0b1100)
  Js.Dict.set(state, "c", 0)

  let instr = And.make("a", "b", "c")

  // Execute
  instr.execute(state)
  let c1 = Js.Dict.get(state, "c")->Belt.Option.getWithDefault(-1)

  // Invert
  instr.invert(state)
  let c2 = Js.Dict.get(state, "c")->Belt.Option.getWithDefault(-1)

  // c should be back to 0
  c1 == 0b1000 && c2 == 0
}

// Run all tests
let runAllTests = (): bool => {
  Js.Console.log("Testing AND/OR instructions...")

  let testResults = [
    ("AND correctness and reversibility", testAndReversibility()),
    ("OR correctness and reversibility", testOrReversibility()),
    ("Ancilla requirement", testAncillaRequirement()),
  ]

  testResults->Belt.Array.forEach(((name, passed)) => {
    if passed {
      Js.Console.log(`✓ ${name}`)
    } else {
      Js.Console.log(`✗ ${name} FAILED`)
    }
  })

  testResults->Belt.Array.every(((_, passed)) => passed)
}
