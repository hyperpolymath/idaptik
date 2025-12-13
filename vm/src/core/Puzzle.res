// Puzzle.res - Puzzle loader and solver for Idaptik VM

// Puzzle type definition
type puzzleStep = {
  op: string,
  target: option<string>,
  targets: option<array<string>>,
  result: option<string>,
}

type puzzle = {
  name: string,
  description: string,
  initialState: Js.Dict.t<int>,
  goalState: option<Js.Dict.t<int>>,
  maxMoves: option<int>,
  steps: option<array<puzzleStep>>,
  allowedInstructions: option<array<string>>,
  difficulty: option<string>,
}

// Parse JSON puzzle file
let parsePuzzle = (jsonString: string): option<puzzle> => {
  try {
    let json = Js.Json.parseExn(jsonString)

    // Helper to get string field
    let getString = (dict, key) => {
      Js.Dict.get(dict, key)
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getWithDefault("")
    }

    // Helper to get object field
    let getObject = (dict, key) => {
      Js.Dict.get(dict, key)
      ->Belt.Option.flatMap(Js.Json.decodeObject)
    }

    // Parse state from JSON object
    let parseState = (obj: option<Js.Dict.t<Js.Json.t>>): Js.Dict.t<int> => {
      switch obj {
      | Some(dict) => {
          let state = Js.Dict.empty()
          Js.Dict.entries(dict)->Belt.Array.forEach(((key, value)) => {
            switch Js.Json.decodeNumber(value) {
            | Some(num) => Js.Dict.set(state, key, int_of_float(num))
            | None => ()
            }
          })
          state
        }
      | None => Js.Dict.empty()
      }
    }

    // Helper to get integer field
    let getInt = (dict, key) => {
      Js.Dict.get(dict, key)
      ->Belt.Option.flatMap(Js.Json.decodeNumber)
      ->Belt.Option.map(int_of_float)
    }

    // Helper to get array of strings
    let getStringArray = (dict, key) => {
      Js.Dict.get(dict, key)
      ->Belt.Option.flatMap(Js.Json.decodeArray)
      ->Belt.Option.map(arr => {
        arr->Belt.Array.keepMap(Js.Json.decodeString)
      })
    }

    switch Js.Json.decodeObject(json) {
    | Some(obj) => {
        let name = getString(obj, "name")
        let description = getString(obj, "description")
        let initialState = parseState(getObject(obj, "initialState"))
        let goalState = getObject(obj, "goalState")->Belt.Option.map(dict => parseState(Some(dict)))
        let maxMoves = getInt(obj, "maxMoves")
        let difficulty = Js.Dict.get(obj, "difficulty")->Belt.Option.flatMap(Js.Json.decodeString)
        let allowedInstructions = getStringArray(obj, "allowedInstructions")

        Some({
          name,
          description,
          initialState,
          goalState,
          maxMoves,
          steps: None,
          allowedInstructions,
          difficulty,
        })
      }
    | None => None
    }
  } catch {
  | _ => None
  }
}

// Load puzzle from file path
@val @scope("Deno") external readTextFileSync: string => string = "readTextFileSync"

let loadPuzzleFromFile = (filePath: string): option<puzzle> => {
  try {
    let content = readTextFileSync(filePath)
    parsePuzzle(content)
  } catch {
  | _ => None
  }
}

// Check if current state matches goal state
let checkGoal = (current: Js.Dict.t<int>, goal: Js.Dict.t<int>): bool => {
  State.statesMatch(current, goal)
}

// Pretty print puzzle info
let printPuzzleInfo = (p: puzzle): unit => {
  Js.Console.log(`╔════════════════════════════════════════╗`)
  Js.Console.log(`║  🧩 ${p.name}`)
  Js.Console.log(`╚════════════════════════════════════════╝`)
  Js.Console.log(``)
  Js.Console.log(`📖 Description: ${p.description}`)

  switch p.difficulty {
  | Some(diff) => Js.Console.log(`🎯 Difficulty: ${diff}`)
  | None => ()
  }

  switch p.maxMoves {
  | Some(max) => Js.Console.log(`⏱️  Max Moves: ${Belt.Int.toString(max)}`)
  | None => ()
  }

  switch p.allowedInstructions {
  | Some(instrs) => Js.Console.log(`🔧 Allowed: ${Js.Array2.joinWith(instrs, ", ")}`)
  | None => ()
  }

  Js.Console.log(``)
  Js.Console.log(`📍 Initial State:`)
  Js.Dict.entries(p.initialState)->Belt.Array.forEach(((key, value)) => {
    Js.Console.log(`   ${key} = ${Belt.Int.toString(value)}`)
  })

  switch p.goalState {
  | Some(goal) => {
      Js.Console.log(``)
      Js.Console.log(`🎯 Goal State:`)
      Js.Dict.entries(goal)->Belt.Array.forEach(((key, value)) => {
        Js.Console.log(`   ${key} = ${Belt.Int.toString(value)}`)
      })
    }
  | None => ()
  }

  Js.Console.log(``)
}
