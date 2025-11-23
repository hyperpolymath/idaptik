// State management for reversible VM

// Create a register state from a list of variable names
let createState = (~variables: array<string>, ~initialValue=0): Js.Dict.t<int> => {
  let state = Js.Dict.empty()
  variables->Belt.Array.forEach(v => {
    Js.Dict.set(state, v, initialValue)
  })
  state
}

// Deep clone the current state (for logging, snapshots, etc.)
let cloneState = (state: Js.Dict.t<int>): Js.Dict.t<int> => {
  let newState = Js.Dict.empty()
  state
  ->Js.Dict.entries
  ->Belt.Array.forEach(((key, value)) => {
    Js.Dict.set(newState, key, value)
  })
  newState
}

// Check if two states are equal (used in puzzle goals)
let statesMatch = (a: Js.Dict.t<int>, b: Js.Dict.t<int>): bool => {
  let keysA = Js.Dict.keys(a)
  let keysB = Js.Dict.keys(b)

  let allKeys = Belt.Set.String.fromArray(
    Belt.Array.concat(keysA, keysB)
  )

  allKeys
  ->Belt.Set.String.toArray
  ->Belt.Array.every(key => {
    Js.Dict.get(a, key) == Js.Dict.get(b, key)
  })
}

// Serialize state to JSON string
let serializeState = (state: Js.Dict.t<int>): string => {
  Js.Json.stringifyAny(state)->Belt.Option.getWithDefault("{}")
}

// Deserialize state from JSON string
let deserializeState = (json: string): Js.Dict.t<int> => {
  try {
    let parsed = Js.Json.parseExn(json)
    let obj = parsed->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
    let result = Js.Dict.empty()
    obj->Js.Dict.entries->Belt.Array.forEach(((key, value)) => {
      let intValue = value->Js.Json.decodeNumber->Belt.Option.map(Belt.Float.toInt)->Belt.Option.getWithDefault(0)
      Js.Dict.set(result, key, intValue)
    })
    result
  } catch {
  | _ => Js.Dict.empty()
  }
}
