// Main game coordinator - ties together engine, rendering, and networking

type gameMode =
  | SinglePlayer
  | Multiplayer({roomId: string})

type inputState = {
  mutable moveX: float,
  mutable moveY: float,
  mutable sprint: bool,
  mutable crouch: bool,
  mutable prone: bool,
}

type t = {
  engine: WasmEngine.t,
  renderer: Renderer.t,
  network: option<Network.t>,
  mode: gameMode,
  playerId: int,
  inputState: inputState,
  mutable lastTime: float,
  mutable isRunning: bool,
}

let create = (
  ~canvas: Renderer.canvas,
  ~mode: gameMode,
  ~width: float,
  ~height: float,
): option<t> => {
  // Create renderer
  let renderer = switch Renderer.create(canvas) {
  | Some(r) => r
  | None => {
      Console.error("Failed to create renderer")
      return None
    }
  }
  
  // Create game engine
  let engine = WasmEngine.createGame(~width, ~height)
  
  // Spawn player
  let playerId = engine->WasmEngine.spawnPlayer(~x=50.0, ~y=50.0)
  
  // Spawn some guards in single player
  switch mode {
  | SinglePlayer => {
      engine->WasmEngine.spawnGuard(~x=200.0, ~y=100.0)->ignore
      engine->WasmEngine.spawnGuard(~x=150.0, ~y=250.0)->ignore
    }
  | Multiplayer(_) => ()
  }
  
  // Create network connection for multiplayer
  let network = switch mode {
  | Multiplayer({roomId}) => {
      let net = Network.create(
        ~endpoint="ws://localhost:4000/socket",
        ~onStateChange=state => {
          Console.log2("Network state:", state)
        },
      )
      
      net->Network.joinRoom(
        ~roomId,
        ~playerId,
        ~onMessage=msg => {
          Console.log2("Received message:", msg)
          // Handle state updates from server
        },
      )
      
      Some(net)
    }
  | SinglePlayer => None
  }
  
  Some({
    engine,
    renderer,
    network,
    mode,
    playerId,
    inputState: {
      moveX: 0.0,
      moveY: 0.0,
      sprint: false,
      crouch: false,
      prone: false,
    },
    lastTime: Date.now(),
    isRunning: false,
  })
}

let handleKeyDown = (game: t, ~key: string): unit => {
  switch key {
  | "w" | "W" | "ArrowUp" => game.inputState.moveY = -1.0
  | "s" | "S" | "ArrowDown" => game.inputState.moveY = 1.0
  | "a" | "A" | "ArrowLeft" => game.inputState.moveX = -1.0
  | "d" | "D" | "ArrowRight" => game.inputState.moveX = 1.0
  | "Shift" => game.inputState.sprint = true
  | "Control" => game.inputState.crouch = true
  | "z" | "Z" => game.inputState.prone = true
  | _ => ()
  }
}

let handleKeyUp = (game: t, ~key: string): unit => {
  switch key {
  | "w" | "W" | "ArrowUp" => game.inputState.moveY = 0.0
  | "s" | "S" | "ArrowDown" => game.inputState.moveY = 0.0
  | "a" | "A" | "ArrowLeft" => game.inputState.moveX = 0.0
  | "d" | "D" | "ArrowRight" => game.inputState.moveX = 0.0
  | "Shift" => game.inputState.sprint = false
  | "Control" => game.inputState.crouch = false
  | "z" | "Z" => game.inputState.prone = false
  | _ => ()
  }
}

let update = (game: t): unit => {
  let currentTime = Date.now()
  let deltaTime = (currentTime -. game.lastTime) /. 1000.0
  game.lastTime = currentTime
  
  // Apply player input to engine
  game.engine->WasmEngine.applyPlayerInput(
    ~playerId=game.playerId,
    ~moveX=game.inputState.moveX,
    ~moveY=game.inputState.moveY,
    ~sprint=game.inputState.sprint,
    ~crouch=game.inputState.crouch,
    ~prone=game.inputState.prone,
  )
  
  // Update game state
  let eventsJson = game.engine->WasmEngine.update(~deltaTime)
  let events = WasmEngine.parseEvents(eventsJson)
  
  // Handle game events
  Array.forEach(events, event => {
    switch event {
    | PlayerDetected({player_id, guard_id, level}) =>
      Console.log(`Player ${Int.toString(player_id)} detected by guard ${Int.toString(guard_id)} at ${Float.toString(level)}`)
    | PlayerHidden({player_id}) =>
      Console.log(`Player ${Int.toString(player_id)} is now hidden`)
    | GuardAlerted({guard_id, position}) =>
      Console.log(`Guard ${Int.toString(guard_id)} alerted at (${Float.toString(position.x)}, ${Float.toString(position.y)})`)
    | ObjectiveComplete({player_id}) =>
      Console.log(`Player ${Int.toString(player_id)} completed objective!`)
    }
  })
  
  // Send input to server in multiplayer
  switch game.network {
  | Some(net) => {
      if game.inputState.moveX != 0.0 || game.inputState.moveY != 0.0 {
        net->Network.sendInput(~input={
          x: game.inputState.moveX,
          y: game.inputState.moveY,
          height: 0.0,
        })
      }
    }
  | None => ()
  }
  
  // Render
  let stateJson = game.engine->WasmEngine.getState()
  switch WasmEngine.parseGameState(stateJson) {
  | Some(state) => game.renderer->Renderer.render(~state)
  | None => Console.error("Failed to parse game state")
  }
}

let start = (game: t): unit => {
  if !game.isRunning {
    game.isRunning = true
    game.lastTime = Date.now()
    
    let rec gameLoop = () => {
      if game.isRunning {
        update(game)
        Window.requestAnimationFrame(gameLoop)->ignore
      }
    }
    
    gameLoop()
    Console.log("Game started!")
  }
}

let stop = (game: t): unit => {
  game.isRunning = false
  Console.log("Game stopped!")
}

let destroy = (game: t): unit => {
  stop(game)
  
  switch game.network {
  | Some(net) => net->Network.disconnect()
  | None => ()
  }
}
