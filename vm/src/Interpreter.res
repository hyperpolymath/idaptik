// Interpreter.res
// Modular, recursive reversible logic interpreter
// Routes logic steps to their appropriate domain-specific implementations

open InterpreterTypes

// Evaluate a single step in the binary domain
let evaluateBinary = (step: gateOp, state: state<bit>): state<bit> => {
  switch step.op {
  | "seq" =>
    switch step.steps {
    | None => state
    | Some(subSteps) =>
      Belt.Array.reduce(subSteps, state, (acc, subStep) => {
        evaluateBinary(subStep, acc)
      })
    }
  | opName => BinaryGates.execute(opName, step, state)
  }
}

// Evaluate a single step in the ternary domain
let evaluateTernary = (step: gateOp, state: state<trit>): state<trit> => {
  switch step.op {
  | "seq" =>
    switch step.steps {
    | None => state
    | Some(subSteps) =>
      Belt.Array.reduce(subSteps, state, (acc, subStep) => {
        evaluateTernary(subStep, acc)
      })
    }
  | opName => TernaryGates.execute(opName, step, state)
  }
}

// Evaluate a single step in the natlog domain
let evaluateNatlog = (step: gateOp, state: state<natSymbol>): state<natSymbol> => {
  switch step.op {
  | "seq" =>
    switch step.steps {
    | None => state
    | Some(subSteps) =>
      Belt.Array.reduce(subSteps, state, (acc, subStep) => {
        evaluateNatlog(subStep, acc)
      })
    }
  | opName => NatlogGates.execute(opName, step, state)
  }
}

// Run a complete puzzle with given steps
module Puzzle = {
  type t<'a> = {
    domain: logicDomain,
    initialState: state<'a>,
    steps: array<gateOp>,
  }

  // Execute a binary puzzle
  let runBinary = (puzzle: t<bit>): state<bit> => {
    Belt.Array.reduce(puzzle.steps, puzzle.initialState, (state, step) => {
      evaluateBinary(step, state)
    })
  }

  // Execute a ternary puzzle
  let runTernary = (puzzle: t<trit>): state<trit> => {
    Belt.Array.reduce(puzzle.steps, puzzle.initialState, (state, step) => {
      evaluateTernary(step, state)
    })
  }

  // Execute a natlog puzzle
  let runNatlog = (puzzle: t<natSymbol>): state<natSymbol> => {
    Belt.Array.reduce(puzzle.steps, puzzle.initialState, (state, step) => {
      evaluateNatlog(step, state)
    })
  }
}
