// Example 7: Puzzle Solver Demo
// Demonstrates using the PuzzleSolver module to solve a puzzle

// Create a simple puzzle programmatically
let createSimplePuzzle = (): Puzzle.puzzle => {
  let initialState = State.createState(~variables=["x", "y", "z"], ~initialValue=0)
  Js.Dict.set(initialState, "x", 5)
  Js.Dict.set(initialState, "y", 3)
  Js.Dict.set(initialState, "z", 0)

  let goalState = State.createState(~variables=["x", "y", "z"], ~initialValue=0)
  Js.Dict.set(goalState, "x", 8)
  Js.Dict.set(goalState, "y", 3)
  Js.Dict.set(goalState, "z", 0)

  {
    name: "Simple Addition",
    description: "Add x and y to get 8",
    initialState,
    goalState: Some(goalState),
    maxMoves: Some(5),
    steps: None,
    allowedInstructions: Some(["ADD", "SUB", "SWAP"]),
    difficulty: Some("beginner"),
  }
}

// Solve the puzzle
let solvePuzzle = (): unit => {
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Puzzle Solver Demo                    ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  let puzzle = createSimplePuzzle()
  Puzzle.printPuzzleInfo(puzzle)

  // Create solver
  let solver = PuzzleSolver.create(puzzle)

  Js.Console.log("Attempting solution...")
  Js.Console.log("")

  // Move 1: ADD x y
  Js.Console.log("Move 1: ADD x y")
  let (solver, result) = PuzzleSolver.executeMove(solver, Add.make("x", "y"))

  switch result {
  | Success(newState) => {
      Js.Console.log("✓ Move successful")
      StateDiff.printDiff(puzzle.initialState, newState)
    }
  | PuzzleSolved => Js.Console.log("🎉 Puzzle solved!")
  | InvalidMove(msg) => Js.Console.log(`✗ Invalid move: ${msg}`)
  | MoveLimitReached => Js.Console.log("✗ Move limit reached")
  }

  Js.Console.log("")
  PuzzleSolver.printStatus(solver)

  // Check if solved
  if PuzzleSolver.isSolved(solver) {
    Js.Console.log("")
    Js.Console.log("╔════════════════════════════════════════╗")
    Js.Console.log("║  🎉 Puzzle Solved!                     ║")
    Js.Console.log("╚════════════════════════════════════════╝")
    Js.Console.log(`Moves used: ${Belt.Int.toString(PuzzleSolver.getMoveCount(solver))}`)

    switch puzzle.maxMoves {
    | Some(max) => {
        let used = PuzzleSolver.getMoveCount(solver)
        if used <= max {
          Js.Console.log(`✓ Under move limit (${Belt.Int.toString(used)}/${Belt.Int.toString(max)})`)
        }
      }
    | None => ()
    }
  }
}

// Demonstrate undo
let demonstrateUndo = (): unit => {
  Js.Console.log("")
  Js.Console.log("╔════════════════════════════════════════╗")
  Js.Console.log("║  Undo Demo                             ║")
  Js.Console.log("╚════════════════════════════════════════╝")
  Js.Console.log("")

  let puzzle = createSimplePuzzle()
  let solver = PuzzleSolver.create(puzzle)

  // Make a move
  Js.Console.log("Making a move: ADD x y")
  let (solver, _) = PuzzleSolver.executeMove(solver, Add.make("x", "y"))
  Js.Console.log(`Moves: ${Belt.Int.toString(PuzzleSolver.getMoveCount(solver))}`)

  // Undo it
  Js.Console.log("Undoing...")
  let (solver, success) = PuzzleSolver.undoMove(solver)

  if success {
    Js.Console.log("✓ Undo successful")
    Js.Console.log(`Moves: ${Belt.Int.toString(PuzzleSolver.getMoveCount(solver))}`)

    // Check state is restored
    let currentState = PuzzleSolver.getCurrentState(solver)
    if State.statesMatch(currentState, puzzle.initialState) {
      Js.Console.log("✓ State perfectly restored to initial")
    }
  } else {
    Js.Console.log("✗ Undo failed")
  }
}

// Run demos
solvePuzzle()
demonstrateUndo()

Js.Console.log("")
Js.Console.log("✓ Puzzle solver demo complete!")
