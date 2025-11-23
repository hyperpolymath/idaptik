// PuzzleSolver.res - Interactive puzzle solving and validation

type moveResult =
  | Success(Js.Dict.t<int>)  // New state after move
  | InvalidMove(string)       // Error message
  | PuzzleSolved              // Goal reached!
  | MoveLimitReached          // Max moves exceeded

type solverState = {
  puzzle: Puzzle.puzzle,
  vm: VM.t,
  moveCount: int,
  solved: bool,
}

// Create a new solver for a puzzle
let create = (puzzle: Puzzle.puzzle): solverState => {
  let initialState = State.cloneState(puzzle.initialState)
  let vm = VM.make(initialState)

  {
    puzzle,
    vm,
    moveCount: 0,
    solved: false,
  }
}

// Check if instruction is allowed for this puzzle
let isInstructionAllowed = (solver: solverState, instrType: string): bool => {
  switch solver.puzzle.allowedInstructions {
  | Some(allowed) => allowed->Belt.Array.some(i => i == instrType)
  | None => true  // If not specified, all instructions allowed
  }
}

// Execute a move
let executeMove = (solver: solverState, instr: Instruction.t): (solverState, moveResult) => {
  // Check if already solved
  if solver.solved {
    (solver, PuzzleSolved)
  } else {
    // Check move limit
    let exceededLimit = switch solver.puzzle.maxMoves {
    | Some(max) => solver.moveCount >= max
    | None => false
    }

    if exceededLimit {
      (solver, MoveLimitReached)
    } else {
      // Check if instruction is allowed
      if !isInstructionAllowed(solver, instr.instructionType) {
        (solver, InvalidMove(`Instruction ${instr.instructionType} not allowed for this puzzle`))
      } else {
        // Execute the move
        VM.run(solver.vm, instr)
        let newMoveCount = solver.moveCount + 1

        // Check if goal reached
        let isSolved = switch solver.puzzle.goalState {
        | Some(goal) => State.statesMatch(VM.getState(solver.vm), goal)
        | None => false
        }

        let newState = {
          ...solver,
          moveCount: newMoveCount,
          solved: isSolved,
        }

        if isSolved {
          (newState, PuzzleSolved)
        } else {
          (newState, Success(VM.getState(solver.vm)))
        }
      }
    }
  }
}

// Undo last move
let undoMove = (solver: solverState): (solverState, bool) => {
  if solver.moveCount == 0 {
    (solver, false)  // Nothing to undo
  } else {
    let success = VM.undo(solver.vm)->Belt.Option.isSome

    if success {
      let newSolver = {
        ...solver,
        moveCount: solver.moveCount - 1,
        solved: false,
      }
      (newSolver, true)
    } else {
      (solver, false)
    }
  }
}

// Get current state
let getCurrentState = (solver: solverState): Js.Dict.t<int> => {
  VM.getState(solver.vm)
}

// Get move count
let getMoveCount = (solver: solverState): int => {
  solver.moveCount
}

// Get remaining moves
let getRemainingMoves = (solver: solverState): option<int> => {
  solver.puzzle.maxMoves->Belt.Option.map(max => max - solver.moveCount)
}

// Check if puzzle is solved
let isSolved = (solver: solverState): bool => {
  solver.solved
}

// Print current status
let printStatus = (solver: solverState): unit => {
  Js.Console.log("════════════════════════════════════════")
  Js.Console.log(`Moves: ${Belt.Int.toString(solver.moveCount)}`)

  switch getRemainingMoves(solver) {
  | Some(remaining) => Js.Console.log(`Remaining: ${Belt.Int.toString(remaining)}`)
  | None => ()
  }

  Js.Console.log("────────────────────────────────────────")
  Js.Console.log("Current State:")

  let currentState = getCurrentState(solver)
  Js.Dict.entries(currentState)->Belt.Array.forEach(((key, value)) => {
    Js.Console.log(`  ${key} = ${Belt.Int.toString(value)}`)
  })

  switch solver.puzzle.goalState {
  | Some(goal) => {
      Js.Console.log("────────────────────────────────────────")
      StateDiff.printMismatches(currentState, goal)
    }
  | None => ()
  }

  Js.Console.log("════════════════════════════════════════")
}

// Validate a complete solution (sequence of instructions)
let validateSolution = (
  puzzle: Puzzle.puzzle,
  instructions: array<Instruction.t>,
): bool => {
  let solver = create(puzzle)

  let rec executeAll = (s: solverState, remaining: array<Instruction.t>): bool => {
    if Belt.Array.length(remaining) == 0 {
      s.solved
    } else {
      let instr = Belt.Array.getExn(remaining, 0)
      let rest = Belt.Array.sliceToEnd(remaining, 1)

      let (newSolver, result) = executeMove(s, instr)

      switch result {
      | Success(_) | PuzzleSolved => executeAll(newSolver, rest)
      | InvalidMove(_) | MoveLimitReached => false
      }
    }
  }

  executeAll(solver, instructions)
}
