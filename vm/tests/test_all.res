// Comprehensive test runner for all Idaptik tests
// Run with: deno run --allow-read tests/test_all.res.js

// Import all test modules
// (In a full implementation, these would be proper imports)

// Test result tracking
type testResult = {
  name: string,
  passed: bool,
  duration: float,
}

type testSuite = {
  suiteName: string,
  results: array<testResult>,
}

// Pretty print test results
let printTestSuite = (suite: testSuite): unit => {
  let totalTests = Belt.Array.length(suite.results)
  let passedTests = suite.results->Belt.Array.keep(r => r.passed)->Belt.Array.length
  let failedTests = totalTests - passedTests

  Js.Console.log("")
  Js.Console.log(`╔${"═"->Js.String2.repeat(50)}╗`)
  Js.Console.log(`║  ${suite.suiteName}`)
  Js.Console.log(`╚${"═"->Js.String2.repeat(50)}╝`)

  suite.results->Belt.Array.forEach(result => {
    let icon = if result.passed { "✓" } else { "✗" }
    let durationStr = Js.Float.toFixedWithPrecision(result.duration, ~digits=2)
    Js.Console.log(`  ${icon} ${result.name} (${durationStr}ms)`)
  })

  Js.Console.log("")
  Js.Console.log(`  Total: ${Belt.Int.toString(totalTests)}`)
  Js.Console.log(`  Passed: ${Belt.Int.toString(passedTests)} ✓`)
  if failedTests > 0 {
    Js.Console.log(`  Failed: ${Belt.Int.toString(failedTests)} ✗`)
  }
}

// Summary of all test suites
let printSummary = (suites: array<testSuite>): unit => {
  let totalTests = suites->Belt.Array.reduce(0, (acc, suite) => {
    acc + Belt.Array.length(suite.results)
  })

  let totalPassed = suites->Belt.Array.reduce(0, (acc, suite) => {
    acc + Belt.Array.length(suite.results->Belt.Array.keep(r => r.passed))
  })

  let totalFailed = totalTests - totalPassed

  Js.Console.log("")
  Js.Console.log("╔════════════════════════════════════════════════╗")
  Js.Console.log("║              TEST SUMMARY                      ║")
  Js.Console.log("╚════════════════════════════════════════════════╝")
  Js.Console.log(`  Test Suites: ${Belt.Int.toString(Belt.Array.length(suites))}`)
  Js.Console.log(`  Total Tests: ${Belt.Int.toString(totalTests)}`)
  Js.Console.log(`  Passed: ${Belt.Int.toString(totalPassed)} ✓`)

  if totalFailed > 0 {
    Js.Console.log(`  Failed: ${Belt.Int.toString(totalFailed)} ✗`)
    Js.Console.log("")
    Js.Console.log("  ⚠️  Some tests failed!")
  } else {
    Js.Console.log("")
    Js.Console.log("  🎉 All tests passed!")
  }

  Js.Console.log("════════════════════════════════════════════════")
}

// Measure execution time
@val @scope("Date") external now: unit => float = "now"

let timeTest = (name: string, testFn: unit => bool): testResult => {
  let startTime = now()
  let passed = try {
    testFn()
  } catch {
  | _ => false
  }
  let endTime = now()
  let duration = endTime -. startTime

  { name, passed, duration }
}

// Core instruction tests
let testCoreInstructions = (): testSuite => {
  Js.Console.log("Running core instruction tests...")

  let results = [
    timeTest("ADD - basic operation", () => {
      let state = State.createState(~variables=["a", "b"], ~initialValue=0)
      Js.Dict.set(state, "a", 10)
      Js.Dict.set(state, "b", 5)
      let instr = Add.make("a", "b")
      instr.execute(state)
      let result = Js.Dict.get(state, "a")->Belt.Option.getWithDefault(0)
      result == 15
    }),
    timeTest("ADD - reversibility", () => {
      let state = State.createState(~variables=["a", "b"], ~initialValue=0)
      Js.Dict.set(state, "a", 10)
      Js.Dict.set(state, "b", 5)
      let original = State.cloneState(state)
      let instr = Add.make("a", "b")
      instr.execute(state)
      instr.invert(state)
      State.statesMatch(state, original)
    }),
    timeTest("SWAP - reversibility", () => {
      let state = State.createState(~variables=["a", "b"], ~initialValue=0)
      Js.Dict.set(state, "a", 10)
      Js.Dict.set(state, "b", 20)
      let original = State.cloneState(state)
      let instr = Swap.make("a", "b")
      instr.execute(state)
      instr.invert(state)
      State.statesMatch(state, original)
    }),
    timeTest("SUB - reversibility", () => {
      let state = State.createState(~variables=["a", "b"], ~initialValue=0)
      Js.Dict.set(state, "a", 10)
      Js.Dict.set(state, "b", 5)
      let original = State.cloneState(state)
      let instr = Sub.make("a", "b")
      instr.execute(state)
      instr.invert(state)
      State.statesMatch(state, original)
    }),
    timeTest("NEGATE - self-inverse", () => {
      let state = State.createState(~variables=["x"], ~initialValue=0)
      Js.Dict.set(state, "x", 42)
      let original = State.cloneState(state)
      let instr = Negate.make("x")
      instr.execute(state)
      instr.execute(state)
      State.statesMatch(state, original)
    }),
  ]

  { suiteName: "Core Instructions", results }
}

// Bitwise instruction tests
let testBitwiseInstructions = (): testSuite => {
  Js.Console.log("Running bitwise instruction tests...")

  let results = [
    timeTest("XOR - self-inverse", () => {
      let state = State.createState(~variables=["a", "b"], ~initialValue=0)
      Js.Dict.set(state, "a", 0b1010)
      Js.Dict.set(state, "b", 0b1100)
      let original = State.cloneState(state)
      let instr = Xor.make("a", "b")
      instr.execute(state)
      instr.execute(state)
      State.statesMatch(state, original)
    }),
    timeTest("FLIP - self-inverse", () => {
      let state = State.createState(~variables=["x"], ~initialValue=0)
      Js.Dict.set(state, "x", 42)
      let original = State.cloneState(state)
      let instr = Flip.make("x")
      instr.execute(state)
      instr.execute(state)
      State.statesMatch(state, original)
    }),
    timeTest("ROL/ROR - mutual inverses", () => {
      let state = State.createState(~variables=["x"], ~initialValue=0)
      Js.Dict.set(state, "x", 0b1010)
      let original = State.cloneState(state)
      let rol = Rol.make("x", ~bits=3, ())
      let ror = Ror.make("x", ~bits=3, ())
      rol.execute(state)
      ror.execute(state)
      State.statesMatch(state, original)
    }),
    timeTest("AND - with ancilla", () => {
      let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
      Js.Dict.set(state, "a", 0b1100)
      Js.Dict.set(state, "b", 0b1010)
      let instr = And.make("a", "b", "c")
      instr.execute(state)
      let result = Js.Dict.get(state, "c")->Belt.Option.getWithDefault(0)
      result == 0b1000
    }),
    timeTest("OR - with ancilla", () => {
      let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
      Js.Dict.set(state, "a", 0b1100)
      Js.Dict.set(state, "b", 0b1010)
      let instr = Or.make("a", "b", "c")
      instr.execute(state)
      let result = Js.Dict.get(state, "c")->Belt.Option.getWithDefault(0)
      result == 0b1110
    }),
  ]

  { suiteName: "Bitwise Instructions", results }
}

// VM tests
let testVM = (): testSuite => {
  Js.Console.log("Running VM tests...")

  let results = [
    timeTest("VM - execute and undo", () => {
      let state = State.createState(~variables=["x", "y"], ~initialValue=0)
      Js.Dict.set(state, "x", 10)
      Js.Dict.set(state, "y", 5)
      let original = State.cloneState(state)
      let vm = VM.make(state)
      VM.run(vm, Add.make("x", "y"))
      VM.undo(vm)->ignore
      State.statesMatch(VM.getState(vm), original)
    }),
    timeTest("VM - multiple undo", () => {
      let state = State.createState(~variables=["x"], ~initialValue=0)
      Js.Dict.set(state, "x", 0)
      let original = State.cloneState(state)
      let vm = VM.make(state)
      VM.run(vm, Add.make("x", "x"))  // x = 0
      VM.run(vm, Add.make("x", "x"))  // x = 0
      VM.run(vm, Add.make("x", "x"))  // x = 0
      VM.undo(vm)->ignore
      VM.undo(vm)->ignore
      VM.undo(vm)->ignore
      State.statesMatch(VM.getState(vm), original)
    }),
    timeTest("VM - history tracking", () => {
      let state = State.createState(~variables=["x"], ~initialValue=0)
      let vm = VM.make(state)
      VM.run(vm, Noop.make())
      VM.run(vm, Noop.make())
      VM.run(vm, Noop.make())
      VM.historyLength(vm) == 3
    }),
  ]

  { suiteName: "Virtual Machine", results }
}

// State tests
let testState = (): testSuite => {
  Js.Console.log("Running state tests...")

  let results = [
    timeTest("State - clone independence", () => {
      let state = State.createState(~variables=["x"], ~initialValue=0)
      Js.Dict.set(state, "x", 42)
      let cloned = State.cloneState(state)
      Js.Dict.set(state, "x", 100)
      let clonedVal = Js.Dict.get(cloned, "x")->Belt.Option.getWithDefault(0)
      clonedVal == 42
    }),
    timeTest("State - serialization", () => {
      let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
      Js.Dict.set(state, "a", 1)
      Js.Dict.set(state, "b", 2)
      Js.Dict.set(state, "c", 3)
      let serialized = State.serializeState(state)
      let deserialized = State.deserializeState(serialized)
      State.statesMatch(state, deserialized)
    }),
    timeTest("State - equality check", () => {
      let state1 = State.createState(~variables=["x", "y"], ~initialValue=0)
      Js.Dict.set(state1, "x", 10)
      Js.Dict.set(state1, "y", 20)
      let state2 = State.cloneState(state1)
      State.statesMatch(state1, state2)
    }),
  ]

  { suiteName: "State Management", results }
}

// Run all test suites
let runAllTests = (): unit => {
  Js.Console.log("╔════════════════════════════════════════════════╗")
  Js.Console.log("║        IDAPTIK TEST SUITE                      ║")
  Js.Console.log("╚════════════════════════════════════════════════╝")

  let suites = [
    testCoreInstructions(),
    testBitwiseInstructions(),
    testVM(),
    testState(),
  ]

  suites->Belt.Array.forEach(printTestSuite)
  printSummary(suites)
}

// Execute
runAllTests()
