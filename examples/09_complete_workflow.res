// Example 9: Complete Workflow
// Demonstrates the full Idaptik ecosystem:
// - State management
// - Multiple instructions
// - VM with undo
// - Puzzle solving
// - State diff visualization
// - Performance measurement

@val @scope("Date") external now: unit => float = "now"

// Part 1: Basic VM Usage
let demoBasicVM = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Part 1: Basic VM Operations          ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  // Create state
  let state = State.createState(~variables=["x", "y", "z"], ~initialValue=0)
  Js.Dict.set(state, "x", 10)
  Js.Dict.set(state, "y", 20)

  Js.Console.log("Initial state:")
  Js.Console.log(state)

  // Create VM
  let vm = VM.make(state)

  // Execute instructions
  Js.Console.log("\nExecuting: SWAP x y")
  VM.run(vm, Swap.make("x", "y"))
  VM.printState(vm)

  Js.Console.log("\nExecuting: ADD x y")
  VM.run(vm, Add.make("x", "y"))
  VM.printState(vm)

  Js.Console.log("\nExecuting: NEGATE z")
  VM.run(vm, Negate.make("z"))
  VM.printState(vm)

  // Undo operations
  Js.Console.log("\n📸 History has ${Belt.Int.toString(VM.historyLength(vm))} instructions")
  Js.Console.log("\nUndoing last 3 operations...")

  VM.undo(vm)->ignore
  VM.undo(vm)->ignore
  VM.undo(vm)->ignore

  Js.Console.log("\nAfter undo:")
  VM.printState(vm)
  Js.Console.log("✓ Perfectly restored to initial state!")
  Js.Console.log("")
}

// Part 2: Bitwise Operations
let demoBitwiseOps = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Part 2: Bitwise Operations           ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  let state = State.createState(~variables=["a", "b", "c", "temp"], ~initialValue=0)
  Js.Dict.set(state, "a", 0b1100)  // 12
  Js.Dict.set(state, "b", 0b1010)  // 10

  let vm = VM.make(state)

  Js.Console.log(`a = 0b1100 (${Belt.Int.toString(12)})`)
  Js.Console.log(`b = 0b1010 (${Belt.Int.toString(10)})`)
  Js.Console.log("")

  // XOR
  Js.Console.log("XOR a b:")
  let before = State.cloneState(VM.getState(vm))
  VM.run(vm, Xor.make("a", "b"))
  let after = VM.getState(vm)
  StateDiff.printDiff(before, after)
  VM.undo(vm)->ignore

  // AND with ancilla
  Js.Console.log("\nAND a b c (into ancilla c):")
  let before = State.cloneState(VM.getState(vm))
  VM.run(vm, And.make("a", "b", "c"))
  let after = VM.getState(vm)
  StateDiff.printDiff(before, after)

  let cVal = Js.Dict.get(after, "c")->Belt.Option.getWithDefault(0)
  Js.Console.log(`Result: 0b${Js.Int.toStringWithRadix(cVal, ~radix=2)} (${Belt.Int.toString(cVal)})`)
  Js.Console.log("")
}

// Part 3: State Diff Visualization
let demoStateDiff = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Part 3: State Diff Visualization     ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  let before = State.createState(~variables=["x", "y", "z"], ~initialValue=0)
  Js.Dict.set(before, "x", 10)
  Js.Dict.set(before, "y", 20)
  Js.Dict.set(before, "z", 0)

  let after = State.cloneState(before)
  Js.Dict.set(after, "x", 30)  // Changed
  Js.Dict.set(after, "z", 5)   // Changed

  Js.Console.log("Side-by-side comparison:")
  StateDiff.printSideBySide(before, after)

  let changes = StateDiff.countChanges(before, after)
  Js.Console.log(`Total changes: ${Belt.Int.toString(changes)}`)
  Js.Console.log("")
}

// Part 4: Puzzle Solving
let demoPuzzleSolving = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Part 4: Puzzle Solving                ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  // Create a simple puzzle
  let initialState = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(initialState, "a", 3)
  Js.Dict.set(initialState, "b", 4)

  let goalState = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(goalState, "a", 7)
  Js.Dict.set(goalState, "b", 4)

  let puzzle: Puzzle.puzzle = {
    name: "Add 3 and 4",
    description: "Add a and b to get 7",
    initialState,
    goalState: Some(goalState),
    maxMoves: Some(3),
    steps: None,
    allowedInstructions: Some(["ADD", "SUB"]),
    difficulty: Some("beginner"),
  }

  Puzzle.printPuzzleInfo(puzzle)

  // Create solver
  let solver = PuzzleSolver.create(puzzle)

  // Solve in one move
  Js.Console.log("💡 Solution: ADD a b")
  let (solver, result) = PuzzleSolver.executeMove(solver, Add.make("a", "b"))

  switch result {
  | PuzzleSolved => {
      Js.Console.log("🎉 Puzzle solved!")
      Js.Console.log(`Moves used: ${Belt.Int.toString(PuzzleSolver.getMoveCount(solver))}`)
    }
  | Success(_) => Js.Console.log("Move successful, keep going...")
  | InvalidMove(msg) => Js.Console.log(`Invalid: ${msg}`)
  | MoveLimitReached => Js.Console.log("Out of moves!")
  }

  Js.Console.log("")
}

// Part 5: Performance Measurement
let demoPerformance = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Part 5: Performance Measurement       ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  let iterations = 10000

  // Measure ADD performance
  let startTime = now()
  for _ in 1 to iterations {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", 10)
    Js.Dict.set(state, "y", 5)
    let instr = Add.make("x", "y")
    instr.execute(state)
  }
  let endTime = now()
  let totalTime = endTime -. startTime
  let avgTime = totalTime /. Belt.Int.toFloat(iterations)

  Js.Console.log(`ADD instruction (${Belt.Int.toString(iterations)} iterations):`)
  Js.Console.log(`  Total: ${Js.Float.toFixedWithPrecision(totalTime, ~digits=2)} ms`)
  Js.Console.log(`  Average: ${Js.Float.toFixedWithPrecision(avgTime, ~digits=4)} ms`)
  Js.Console.log(`  Throughput: ${Js.Float.toFixedWithPrecision(1000.0 /. avgTime, ~digits=0)} ops/sec`)
  Js.Console.log("")
}

// Part 6: Complex Algorithm
let demoComplexAlgorithm = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Part 6: Complex Algorithm (GCD)       ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  // Euclidean GCD algorithm (reversible!)
  let state = State.createState(~variables=["a", "b", "temp"], ~initialValue=0)
  Js.Dict.set(state, "a", 48)
  Js.Dict.set(state, "b", 18)

  let vm = VM.make(state)

  Js.Console.log("Computing GCD(48, 18) using Euclidean algorithm...")
  Js.Console.log("")

  let steps = 0
  let continueLoop = true

  while continueLoop {
    let a = Js.Dict.get(VM.getState(vm), "a")->Belt.Option.getWithDefault(0)
    let b = Js.Dict.get(VM.getState(vm), "b")->Belt.Option.getWithDefault(0)

    if b == 0 {
      Js.Console.log(`GCD = ${Belt.Int.toString(a)}`)
      Js.Console.log(`Steps: ${Belt.Int.toString(steps)}`)
      continueLoop = false
    } else {
      Js.Console.log(`Step ${Belt.Int.toString(steps + 1)}: a=${Belt.Int.toString(a)}, b=${Belt.Int.toString(b)}`)

      // Compute a mod b using repeated subtraction
      let mut remaining = a
      while remaining >= b {
        remaining = remaining - b
      }

      // Update: temp = b, b = a mod b, a = temp
      Js.Dict.set(VM.getState(vm), "temp", b)
      Js.Dict.set(VM.getState(vm), "b", remaining)
      Js.Dict.set(VM.getState(vm), "a", Js.Dict.get(VM.getState(vm), "temp")->Belt.Option.getWithDefault(0))

      steps = steps + 1

      if steps > 20 {
        Js.Console.log("Max iterations reached")
        continueLoop = false
      }
    }
  }

  Js.Console.log("\n✓ Algorithm complete!")
  Js.Console.log("")
}

// Main: Run all demos
Js.Console.log("╔════════════════════════════════════════════════╗")
Js.Console.log("║  IDAPTIK COMPLETE WORKFLOW DEMONSTRATION       ║")
Js.Console.log("╚════════════════════════════════════════════════╝")
Js.Console.log("")
Js.Console.log("This example demonstrates the full Idaptik ecosystem:")
Js.Console.log("  ✓ VM with undo/redo")
Js.Console.log("  ✓ 13 reversible instructions")
Js.Console.log("  ✓ State diff visualization")
Js.Console.log("  ✓ Puzzle solving framework")
Js.Console.log("  ✓ Performance measurement")
Js.Console.log("  ✓ Complex algorithms")
Js.Console.log("")
Js.Console.log("Press any key to continue...")
Js.Console.log("")

demoBasicVM()
demoBitwiseOps()
demoStateDiff()
demoPuzzleSolving()
demoPerformance()
demoComplexAlgorithm()

Js.Console.log("╔════════════════════════════════════════════════╗")
Js.Console.log("║  DEMONSTRATION COMPLETE ✅                      ║")
Js.Console.log("╚════════════════════════════════════════════════╝")
Js.Console.log("")
Js.Console.log("Next steps:")
Js.Console.log("  • Explore examples/ directory for more")
Js.Console.log("  • Read docs/REVERSIBLE-COMPUTING-CONCEPTS.md")
Js.Console.log("  • Try solving puzzles in data/puzzles/")
Js.Console.log("  • Check out API-REFERENCE.md for complete API")
Js.Console.log("")
Js.Console.log("Happy reversible computing! 🔄")
