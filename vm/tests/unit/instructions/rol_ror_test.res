// Tests for ROL and ROR instructions (rotation)

// Test ROL reversibility
let testRolReversibility = (): bool => {
  let testCases = [
    (0b1010, 1),   // Basic rotation
    (0b1111, 4),   // Multiple bits
    (1, 1),        // Single bit
    (0, 8),        // Zero rotation
    (0xFF, 8),     // Full byte
  ]

  testCases->Belt.Array.every(((value, bits)) => {
    let state = State.createState(~variables=["x"], ~initialValue=0)
    Js.Dict.set(state, "x", value)

    let original = State.cloneState(state)
    let instr = Rol.make("x", ~bits, ())

    // Execute ROL
    instr.execute(state)

    // Invert (should be ROR)
    instr.invert(state)

    // Should match original
    State.statesMatch(state, original)
  })
}

// Test ROR reversibility
let testRorReversibility = (): bool => {
  let testCases = [
    (0b1010, 1),
    (0b1111, 4),
    (1, 1),
    (0, 8),
    (0xFF, 8),
  ]

  testCases->Belt.Array.every(((value, bits)) => {
    let state = State.createState(~variables=["x"], ~initialValue=0)
    Js.Dict.set(state, "x", value)

    let original = State.cloneState(state)
    let instr = Ror.make("x", ~bits, ())

    // Execute ROR
    instr.execute(state)

    // Invert (should be ROL)
    instr.invert(state)

    // Should match original
    State.statesMatch(state, original)
  })
}

// Test ROL/ROR are mutual inverses
let testRolRorInverse = (): bool => {
  let testCases = [0b1010, 0b1111, 1, 0xFF, 42]

  testCases->Belt.Array.every(value => {
    let state = State.createState(~variables=["x"], ~initialValue=0)
    Js.Dict.set(state, "x", value)

    let original = State.cloneState(state)

    // ROL then ROR
    let rol = Rol.make("x", ~bits=3, ())
    let ror = Ror.make("x", ~bits=3, ())

    rol.execute(state)
    ror.execute(state)

    // Should match original
    State.statesMatch(state, original)
  })
}

// Run all tests
let runAllTests = (): bool => {
  Js.Console.log("Testing ROL/ROR instructions...")

  let testResults = [
    ("ROL reversibility", testRolReversibility()),
    ("ROR reversibility", testRorReversibility()),
    ("ROL/ROR are inverses", testRolRorInverse()),
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
