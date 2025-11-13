// Main entry point for IDApTIK

@@warning("-27") // Suppress unused variable warnings

// Get canvas element
let canvas = Document.querySelector("#game-canvas")

switch canvas {
| Some(element) => {
    // Create game instance
    let game = Game.create(
      ~canvas=element,
      ~mode=SinglePlayer,
      ~width=800.0,
      ~height=600.0,
    )
    
    switch game {
    | Some(g) => {
        // Set up input handlers
        Document.addEventListener("keydown", event => {
          g->Game.handleKeyDown(~key=event["key"])
          event["preventDefault"]()
        })
        
        Document.addEventListener("keyup", event => {
          g->Game.handleKeyUp(~key=event["key"])
          event["preventDefault"]()
        })
        
        // Start the game
        g->Game.start()
        
        Console.log("🎮 IDApTIK initialized!")
        Console.log("Controls:")
        Console.log("  WASD / Arrow Keys - Move")
        Console.log("  Shift - Sprint")
        Console.log("  Control - Crouch")
        Console.log("  Z - Prone")
        
        // Store game instance for debugging
        Window["game"] = g
      }
    | None => Console.error("Failed to create game instance")
    }
  }
| None => Console.error("Canvas element #game-canvas not found")
}
