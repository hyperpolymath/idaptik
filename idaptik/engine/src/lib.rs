pub mod game;
pub mod stealth;
pub mod wasm;

// Re-export main types for convenience
pub use game::{GameSystem, PlayerInput, Entity, World, Position};
pub use stealth::*;
pub use wasm::WasmGame;
