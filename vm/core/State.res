// State.res
// State management for the reversible VM

type state = Belt.Map.String.t<int>

// Create a register state from a list of variable names
let createState = (variables: array<string>, ~initialValue=0, ()): state => {
  Belt.Array.reduce(variables, Belt.Map.String.empty, (acc, v) => {
    Belt.Map.String.set(acc, v, initialValue)
  })
}

// Clone the current state (for logging, snapshots, etc.)
let cloneState = (s: state): state => s

// Check if two states are equal (used in puzzle goals)
let statesMatch = (a: state, b: state): bool => {
  let keysA = Belt.Map.String.keysToArray(a)
  let keysB = Belt.Map.String.keysToArray(b)
  let allKeys = Belt.Set.String.fromArray(Belt.Array.concat(keysA, keysB))

  Belt.Set.String.every(allKeys, k => {
    Belt.Map.String.get(a, k) == Belt.Map.String.get(b, k)
  })
}

// Serialize state to JSON string
let serializeState = (s: state): string => {
  let pairs = Belt.Map.String.toArray(s)
  let json = Belt.Array.map(pairs, ((k, v)) => `"${k}":${Belt.Int.toString(v)}`)
  "{" ++ Belt.Array.joinWith(json, ",", x => x) ++ "}"
}

// Get a value from state
let get = (s: state, key: string): option<int> => {
  Belt.Map.String.get(s, key)
}

// Set a value in state
let set = (s: state, key: string, value: int): state => {
  Belt.Map.String.set(s, key, value)
}

// Update a value in state with a function
let update = (s: state, key: string, f: int => int): state => {
  switch Belt.Map.String.get(s, key) {
  | None => s
  | Some(v) => Belt.Map.String.set(s, key, f(v))
  }
}
