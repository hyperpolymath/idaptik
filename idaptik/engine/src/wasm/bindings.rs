use wasm_bindgen::prelude::*;
use crate::game::{GameSystem, PlayerInput, GameEvent};

/// WASM-exported game instance
#[wasm_bindgen]
pub struct WasmGame {
    system: GameSystem,
}

#[wasm_bindgen]
impl WasmGame {
    /// Create a new game instance
    #[wasm_bindgen(constructor)]
    pub fn new(width: f32, height: f32) -> Self {
        // Set panic hook for better error messages in browser
        #[cfg(feature = "console_error_panic_hook")]
        console_error_panic_hook::set_once();

        Self {
            system: GameSystem::new(width, height),
        }
    }

    /// Spawn a player and return their ID
    #[wasm_bindgen(js_name = spawnPlayer)]
    pub fn spawn_player(&mut self, x: f32, y: f32) -> u32 {
        self.system.spawn_player(x, y)
    }

    /// Spawn a guard and return their ID
    #[wasm_bindgen(js_name = spawnGuard)]
    pub fn spawn_guard(&mut self, x: f32, y: f32) -> u32 {
        self.system.spawn_guard(x, y)
    }

    /// Add an obstacle to the world
    #[wasm_bindgen(js_name = addObstacle)]
    pub fn add_obstacle(&mut self, x: f32, y: f32, radius: f32) {
        self.system.add_obstacle(x, y, radius);
    }

    /// Add a light source
    #[wasm_bindgen(js_name = addLight)]
    pub fn add_light(&mut self, x: f32, y: f32, radius: f32, intensity: f32) {
        self.system.add_light(x, y, radius, intensity);
    }

    /// Update game state
    /// Returns JSON array of game events
    #[wasm_bindgen]
    pub fn update(&mut self, delta_time: f32) -> String {
        let events = self.system.update(delta_time);
        serde_json::to_string(&events).unwrap_or_else(|_| "[]".to_string())
    }

    /// Apply player input
    #[wasm_bindgen(js_name = applyPlayerInput)]
    pub fn apply_player_input(
        &mut self,
        player_id: u32,
        move_x: f32,
        move_y: f32,
        sprint: bool,
        crouch: bool,
        prone: bool,
    ) {
        let input = PlayerInput {
            move_x,
            move_y,
            sprint,
            crouch,
            prone,
        };
        self.system.apply_player_input(player_id, input);
    }

    /// Get current game state as JSON
    #[wasm_bindgen(js_name = getState)]
    pub fn get_state(&self) -> String {
        self.system.serialize_state().unwrap_or_else(|_| "{}".to_string())
    }

    /// Set game state from JSON (for network sync)
    #[wasm_bindgen(js_name = setState)]
    pub fn set_state(&mut self, state_json: &str) -> bool {
        self.system.deserialize_state(state_json).is_ok()
    }

    /// Get game time
    #[wasm_bindgen(js_name = getTime)]
    pub fn get_time(&self) -> f32 {
        self.system.time
    }
}
