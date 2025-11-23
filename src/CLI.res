// CLI for idaptik-reversible

// Parse command line arguments from Deno
@val @scope("Deno") external args: array<string> = "args"

// Console helpers
let logInfo = (msg: string): unit => Js.log(`[INFO] ${msg}`)
let logError = (msg: string): unit => Js.log(`[ERROR] ${msg}`)
let logSuccess = (msg: string): unit => Js.log(`[SUCCESS] ${msg}`)

// Display help message
let showHelp = (): unit => {
  Js.log("
╔════════════════════════════════════════════════════════╗
║          IDAPTIK - Reversible Logic Interpreter        ║
╚════════════════════════════════════════════════════════╝

USAGE:
  deno run --allow-read --allow-write src/CLI.res.js [COMMAND] [OPTIONS]

COMMANDS:
  run <puzzle>       Run a puzzle by name
  demo               Run demonstration of VM capabilities
  test               Run instruction tests
  help               Show this help message

EXAMPLES:
  deno run --allow-read src/CLI.res.js demo
  deno run --allow-read src/CLI.res.js run vault_7
  deno run --allow-read src/CLI.res.js test

ABOUT:
  Idaptik is a reversible computation VM where every operation
  has an inverse. Perfect for puzzles, undo systems, and
  reversible algorithms.

LICENSE: AGPL-3.0
AUTHORS: Joshua & Jonathan Jewell
")
}

// Demo function showing VM capabilities
let runDemo = (): unit => {
  logInfo("Starting reversible VM demo...")

  // Create initial state
  let initial = State.createState(~variables=["x", "y", "z"], ~initialValue=0)
  Js.Dict.set(initial, "x", 5)
  Js.Dict.set(initial, "y", 3)

  logInfo("Initial state: x=5, y=3, z=0")

  // Create VM
  let vm = VM.make(initial)

  // Execute instructions
  logInfo("Executing: ADD x y (x = x + y)")
  VM.run(vm, Add.make("x", "y"))
  VM.printState(vm)

  logInfo("Executing: SWAP x z")
  VM.run(vm, Swap.make("x", "z"))
  VM.printState(vm)

  logInfo("Executing: NEGATE y")
  VM.run(vm, Negate.make("y"))
  VM.printState(vm)

  logInfo("\\nNow reversing operations...")

  logInfo("Undoing NEGATE y")
  let _ = VM.undo(vm)
  VM.printState(vm)

  logInfo("Undoing SWAP x z")
  let _ = VM.undo(vm)
  VM.printState(vm)

  logInfo("Undoing ADD x y")
  let _ = VM.undo(vm)
  VM.printState(vm)

  logSuccess("Demo complete! Notice how undo perfectly reversed all operations.")
}

// Run instruction tests
let runTests = (): unit => {
  logInfo("Running instruction tests...")

  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 10)
  Js.Dict.set(state, "b", 5)

  // Test ADD
  let addInstr = Add.make("a", "b")
  addInstr.execute(state)
  let aVal = Js.Dict.get(state, "a")->Belt.Option.getWithDefault(0)
  if aVal == 15 {
    logSuccess("✓ ADD test passed")
  } else {
    logError("✗ ADD test failed")
  }

  addInstr.invert(state)
  let aVal2 = Js.Dict.get(state, "a")->Belt.Option.getWithDefault(0)
  if aVal2 == 10 {
    logSuccess("✓ ADD invert test passed")
  } else {
    logError("✗ ADD invert test failed")
  }

  // Test SWAP
  let swapInstr = Swap.make("a", "b")
  swapInstr.execute(state)
  let aVal3 = Js.Dict.get(state, "a")->Belt.Option.getWithDefault(0)
  let bVal3 = Js.Dict.get(state, "b")->Belt.Option.getWithDefault(0)
  if aVal3 == 5 && bVal3 == 10 {
    logSuccess("✓ SWAP test passed")
  } else {
    logError("✗ SWAP test failed")
  }

  swapInstr.invert(state)
  let aVal4 = Js.Dict.get(state, "a")->Belt.Option.getWithDefault(0)
  let bVal4 = Js.Dict.get(state, "b")->Belt.Option.getWithDefault(0)
  if aVal4 == 10 && bVal4 == 5 {
    logSuccess("✓ SWAP invert test passed")
  } else {
    logError("✗ SWAP invert test failed")
  }

  logSuccess("All tests passed!")
}

// Main entry point
let main = (): unit => {
  let command = Belt.Array.get(args, 0)

  switch command {
  | Some("demo") => runDemo()
  | Some("test") => runTests()
  | Some("help") | Some("-h") | Some("--help") => showHelp()
  | Some("run") => {
      switch Belt.Array.get(args, 1) {
      | Some(puzzleName) => {
          let puzzlePath = `data/puzzles/${puzzleName}.json`
          logInfo(`Loading puzzle: ${puzzlePath}`)

          switch Puzzle.loadPuzzleFromFile(puzzlePath) {
          | Some(puzzle) => {
              Puzzle.printPuzzleInfo(puzzle)
              logInfo("Puzzle loaded! Interactive solving not yet implemented.")
              logInfo("Try the demo: deno run --allow-read src/CLI.res.js demo")
            }
          | None => {
              logError(`Failed to load puzzle: ${puzzlePath}`)
              logInfo("Available puzzles in data/puzzles/:")
              logInfo("  beginner_01_simple_add, beginner_02_swap_values, ...")
            }
          }
        }
      | None => {
          logError("Please specify a puzzle name")
          logInfo("Usage: deno run --allow-read src/CLI.res.js run <puzzle_name>")
        }
      }
    }
  | Some(cmd) => {
      logError(`Unknown command: ${cmd}`)
      showHelp()
    }
  | None => {
      logInfo("No command provided")
      showHelp()
    }
  }
}

// Run main
main()
