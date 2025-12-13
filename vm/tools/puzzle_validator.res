// Puzzle Validator Tool
// Validates puzzle JSON files against schema and checks for common issues

// Validation result type
type validationIssue = {
  severity: [#error | #warning | #info],
  field: string,
  message: string,
}

type validationResult = {
  valid: bool,
  issues: array<validationIssue>,
}

// Add an issue to results
let addIssue = (
  issues: array<validationIssue>,
  severity: [#error | #warning | #info],
  field: string,
  message: string,
): array<validationIssue> => {
  Belt.Array.concat(issues, [{severity, field, message}])
}

// Validate puzzle structure
let validatePuzzle = (puzzle: Puzzle.puzzle): validationResult => {
  let issues = []

  // Check name
  let issues = if Js.String2.length(puzzle.name) == 0 {
    addIssue(issues, #error, "name", "Name cannot be empty")
  } else if Js.String2.length(puzzle.name) > 100 {
    addIssue(issues, #warning, "name", "Name is very long (>100 chars)")
  } else {
    issues
  }

  // Check description
  let issues = if Js.String2.length(puzzle.description) == 0 {
    addIssue(issues, #error, "description", "Description cannot be empty")
  } else if Js.String2.length(puzzle.description) > 500 {
    addIssue(issues, #warning, "description", "Description is very long (>500 chars)")
  } else {
    issues
  }

  // Check initialState
  let issues = if Js.Dict.keys(puzzle.initialState)->Belt.Array.length == 0 {
    addIssue(issues, #error, "initialState", "Initial state must have at least one variable")
  } else {
    issues
  }

  // Check variable names
  let issues = {
    let varNames = Js.Dict.keys(puzzle.initialState)
    varNames->Belt.Array.reduce(issues, (acc, varName) => {
      // Check if variable name is valid (alphanumeric + underscore, starts with letter)
      let validPattern = %re("/^[a-zA-Z_][a-zA-Z0-9_]*$/")
      if Js.Re.test_(validPattern, varName) {
        acc
      } else {
        addIssue(acc, #error, "initialState", `Invalid variable name: "${varName}"`)
      }
    })
  }

  // Check goalState if present
  let issues = switch puzzle.goalState {
  | Some(goal) => {
      // Check that goal variables exist in initial state
      let goalVars = Js.Dict.keys(goal)
      let initialVars = Js.Dict.keys(puzzle.initialState)

      goalVars->Belt.Array.reduce(issues, (acc, goalVar) => {
        if initialVars->Belt.Array.some(iv => iv == goalVar) {
          acc
        } else {
          addIssue(acc, #warning, "goalState", `Goal variable "${goalVar}" not in initial state`)
        }
      })
    }
  | None => {
      addIssue(issues, #info, "goalState", "No goal state specified - open-ended puzzle")
    }
  }

  // Check maxMoves
  let issues = switch puzzle.maxMoves {
  | Some(max) => {
      if max <= 0 {
        addIssue(issues, #error, "maxMoves", "Max moves must be positive")
      } else if max > 1000 {
        addIssue(issues, #warning, "maxMoves", "Very high move limit (>1000)")
      } else {
        issues
      }
    }
  | None => {
      addIssue(issues, #info, "maxMoves", "No move limit - unlimited attempts")
    }
  }

  // Check difficulty
  let issues = switch puzzle.difficulty {
  | Some(diff) => {
      let validDifficulties = ["beginner", "intermediate", "advanced", "expert"]
      if validDifficulties->Belt.Array.some(v => v == diff) {
        issues
      } else {
        addIssue(issues, #warning, "difficulty", `Unknown difficulty: "${diff}"`)
      }
    }
  | None => {
      addIssue(issues, #info, "difficulty", "No difficulty specified")
    }
  }

  // Check allowedInstructions
  let issues = switch puzzle.allowedInstructions {
  | Some(instrs) => {
      if Belt.Array.length(instrs) == 0 {
        addIssue(issues, #warning, "allowedInstructions", "Empty instruction list - no moves possible")
      } else {
        // Validate instruction names
        let validInstrs = ["ADD", "SUB", "SWAP", "NEGATE", "NOOP", "XOR", "FLIP", "ROL", "ROR", "AND", "OR", "MUL", "DIV"]
        instrs->Belt.Array.reduce(issues, (acc, instr) => {
          if validInstrs->Belt.Array.some(v => v == instr) {
            acc
          } else {
            addIssue(acc, #error, "allowedInstructions", `Unknown instruction: "${instr}"`)
          }
        })
      }
    }
  | None => {
      addIssue(issues, #info, "allowedInstructions", "All instructions allowed")
    }
  }

  // Check for potential issues
  let issues = switch (puzzle.goalState, puzzle.maxMoves) {
  | (Some(_), None) => {
      addIssue(issues, #warning, "design", "Has goal but no move limit - may be too easy")
    }
  | (None, Some(_)) => {
      addIssue(issues, #warning, "design", "Has move limit but no goal - unclear objective")
    }
  | _ => issues
  }

  // Determine if valid (no errors)
  let hasErrors = issues->Belt.Array.some(issue => {
    switch issue.severity {
    | #error => true
    | _ => false
    }
  })

  {
    valid: !hasErrors,
    issues,
  }
}

// Pretty print validation result
let printValidationResult = (puzzle: Puzzle.puzzle, result: validationResult): unit => {
  Js.Console.log("╔════════════════════════════════════════════════╗")
  Js.Console.log(`║  Puzzle Validation: ${puzzle.name}`)
  Js.Console.log("╚════════════════════════════════════════════════╝")
  Js.Console.log("")

  if result.valid {
    Js.Console.log("✅ Puzzle is VALID")
  } else {
    Js.Console.log("❌ Puzzle has ERRORS")
  }

  Js.Console.log("")

  // Group by severity
  let errors = result.issues->Belt.Array.keep(i => i.severity == #error)
  let warnings = result.issues->Belt.Array.keep(i => i.severity == #warning)
  let infos = result.issues->Belt.Array.keep(i => i.severity == #info)

  // Print errors
  if Belt.Array.length(errors) > 0 {
    Js.Console.log(`🔴 Errors (${Belt.Int.toString(Belt.Array.length(errors))})`)
    errors->Belt.Array.forEach(issue => {
      Js.Console.log(`   [${issue.field}] ${issue.message}`)
    })
    Js.Console.log("")
  }

  // Print warnings
  if Belt.Array.length(warnings) > 0 {
    Js.Console.log(`🟡 Warnings (${Belt.Int.toString(Belt.Array.length(warnings))})`)
    warnings->Belt.Array.forEach(issue => {
      Js.Console.log(`   [${issue.field}] ${issue.message}`)
    })
    Js.Console.log("")
  }

  // Print info
  if Belt.Array.length(infos) > 0 {
    Js.Console.log(`ℹ️  Info (${Belt.Int.toString(Belt.Array.length(infos))})`)
    infos->Belt.Array.forEach(issue => {
      Js.Console.log(`   [${issue.field}] ${issue.message}`)
    })
    Js.Console.log("")
  }

  Js.Console.log("════════════════════════════════════════════════")
}

// Validate a puzzle file
let validatePuzzleFile = (filePath: string): unit => {
  Js.Console.log(`Validating: ${filePath}`)
  Js.Console.log("")

  switch Puzzle.loadPuzzleFromFile(filePath) {
  | Some(puzzle) => {
      let result = validatePuzzle(puzzle)
      printValidationResult(puzzle, result)
    }
  | None => {
      Js.Console.log("❌ Failed to load puzzle file")
      Js.Console.log("   Check JSON syntax and file path")
    }
  }
}

// Validate all puzzles in a directory
// (Would require directory reading capability - placeholder for future)
let validateAllPuzzles = (directory: string): unit => {
  Js.Console.log(`Validating all puzzles in: ${directory}`)
  Js.Console.log("(Directory scanning not yet implemented)")
  Js.Console.log("")
  Js.Console.log("💡 Run individually:")
  Js.Console.log("   deno run --allow-read tools/puzzle_validator.res.js data/puzzles/puzzle_name.json")
}

// Example usage
let exampleValidation = (): unit => {
  Js.Console.log("╔════════════════════════════════════════════════╗")
  Js.Console.log("║  Puzzle Validator Tool                         ║")
  Js.Console.log("╚════════════════════════════════════════════════╝")
  Js.Console.log("")
  Js.Console.log("Usage:")
  Js.Console.log("  deno run --allow-read tools/puzzle_validator.res.js <puzzle_file.json>")
  Js.Console.log("")
  Js.Console.log("Example:")
  Js.Console.log("  deno run --allow-read tools/puzzle_validator.res.js data/puzzles/beginner_01_simple_add.json")
  Js.Console.log("")
}

// If run directly, show usage
exampleValidation()
