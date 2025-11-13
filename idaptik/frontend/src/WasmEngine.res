// Bindings to the Rust WASM game engine

type t

type gameState = {
  entities: array<entity>,
  obstacles: array<obstacle>,
  lights: array<lightSource>,
  width: float,
  height: float,
  ambient_light: float,
}

and entity = {
  id: int,
  entity_type: string,
  position: position,
  rotation: float,
  velocity: (float, float),
  stance: string,
  state: string,
  visible: bool,
  visibility_radius: float,
  field_of_view: float,
  noise_level: float,
  detection_level: float,
  light_exposure: float,
  speed: float,
  health: float,
}

and position = {
  x: float,
  y: float,
  height: float,
}

and obstacle = {
  position: position,
  radius: float,
  blocks_vision: bool,
  blocks_sound: bool,
  provides_cover: bool,
}

and lightSource = {
  position: position,
  radius: float,
  intensity: float,
}

type gameEvent =
  | PlayerDetected({player_id: int, guard_id: int, level: float})
  | PlayerHidden({player_id: int})
  | GuardAlerted({guard_id: int, position: position})
  | ObjectiveComplete({player_id: int})

@module("../engine/pkg/idaptik_engine.js")
external make: (~width: float, ~height: float) => t = "WasmGame"

@send external spawnPlayer: (t, ~x: float, ~y: float) => int = "spawnPlayer"
@send external spawnGuard: (t, ~x: float, ~y: float) => int = "spawnGuard"
@send external addObstacle: (t, ~x: float, ~y: float, ~radius: float) => unit = "addObstacle"
@send
external addLight: (t, ~x: float, ~y: float, ~radius: float, ~intensity: float) => unit =
  "addLight"

@send external update: (t, ~deltaTime: float) => string = "update"
@send external getState: t => string = "getState"
@send external setState: (t, ~stateJson: string) => bool = "setState"
@send external getTime: t => float = "getTime"

@send
external applyPlayerInput: (
  t,
  ~playerId: int,
  ~moveX: float,
  ~moveY: float,
  ~sprint: bool,
  ~crouch: bool,
  ~prone: bool,
) => unit = "applyPlayerInput"

// Helper functions

let parseGameState = (json: string): option<gameState> => {
  try {
    Some(JSON.parseExn(json))
  } catch {
  | _ => None
  }
}

let parseEvents = (json: string): array<gameEvent> => {
  try {
    let raw = JSON.parseExn(json)
    // Parse event array from JSON
    // This is simplified - in practice you'd need proper JSON parsing
    []
  } catch {
  | _ => []
  }
}

// Create a new game instance with initial setup
let createGame = (~width: float, ~height: float): t => {
  let game = make(~width, ~height)
  
  // Set up initial world
  // Add some obstacles
  game->addObstacle(~x=50.0, ~y=50.0, ~radius=10.0)
  game->addObstacle(~x=150.0, ~y=100.0, ~radius=15.0)
  game->addObstacle(~x=200.0, ~y=200.0, ~radius=12.0)
  
  // Add lighting
  game->addLight(~x=100.0, ~y=100.0, ~radius=80.0, ~intensity=0.8)
  game->addLight(~x=300.0, ~y=200.0, ~radius=60.0, ~intensity=0.6)
  
  game
}
