use bevy::prelude::*;
use bevy::log::{warn, error};
use std::io::{self, BufRead, Write};
use std::sync::{Arc, Mutex};
use std::sync::mpsc::{channel, Receiver, Sender};
use std::thread;
use crate::game_state::{ServerMessage, ClientMessage, GameState, GameEntity};

/// Resource that holds channels for Port communication
/// Wrapped in Arc<Mutex<>> to make them thread-safe for Bevy
#[derive(Resource, Clone)]
pub struct PortChannels {
    pub to_elixir: Arc<Mutex<Sender<ClientMessage>>>,
    pub from_elixir: Arc<Mutex<Receiver<ServerMessage>>>,
}

/// Initialize Port communication channels
/// Spawns background thread to handle stdin/stdout
pub fn init_port_communication() -> PortChannels {
    let (tx_to_elixir, rx_to_elixir) = channel::<ClientMessage>();
    let (tx_from_elixir, rx_from_elixir) = channel::<ServerMessage>();

    // Spawn thread to read from stdin (messages FROM Elixir)
    thread::spawn(move || {
        let stdin = io::stdin();
        let mut reader = stdin.lock();
        let mut buffer = String::new();

        loop {
            buffer.clear();
            match reader.read_line(&mut buffer) {
                Ok(0) => break, // EOF - Elixir process closed
                Ok(_) => {
                    // Parse JSON message from Elixir
                    match serde_json::from_str::<ServerMessage>(buffer.trim()) {
                        Ok(msg) => {
                            if tx_from_elixir.send(msg).is_err() {
                                break; // Game closed
                            }
                        }
                        Err(e) => {
                            eprintln!("Failed to parse message from Elixir: {}", e);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("Error reading from stdin: {}", e);
                    break;
                }
            }
        }
    });

    // Spawn thread to write to stdout (messages TO Elixir)
    thread::spawn(move || {
        let stdout = io::stdout();
        let mut writer = stdout.lock();

        while let Ok(msg) = rx_to_elixir.recv() {
            match serde_json::to_string(&msg) {
                Ok(json) => {
                    if writeln!(writer, "{}", json).is_err() {
                        break; // Elixir process closed
                    }
                    if writer.flush().is_err() {
                        break;
                    }
                }
                Err(e) => {
                    eprintln!("Failed to serialize message to Elixir: {}", e);
                }
            }
        }
    });

    PortChannels {
        to_elixir: Arc::new(Mutex::new(tx_to_elixir)),
        from_elixir: Arc::new(Mutex::new(rx_from_elixir)),
    }
}

/// System to receive messages from Elixir and update game state
pub fn receive_from_elixir(
    port_channels: Res<PortChannels>,
    mut game_state: ResMut<GameState>,
) {
    // Lock the receiver
    let Ok(receiver) = port_channels.from_elixir.lock() else {
        return;
    };

    // Process all available messages from Elixir
    while let Ok(msg) = receiver.try_recv() {
        match msg.msg_type {
            crate::game_state::MessageType::StateUpdate => {
                // Full state update from server
                if let Ok(entities) = serde_json::from_value::<Vec<GameEntity>>(msg.data) {
                    game_state.entities = entities;
                }
            }
            crate::game_state::MessageType::EntitySpawned => {
                // New entity added
                if let Ok(entity) = serde_json::from_value::<GameEntity>(msg.data) {
                    game_state.entities.push(entity);
                }
            }
            crate::game_state::MessageType::EntityRemoved => {
                // Entity removed
                if let Some(entity_id) = msg.data.as_u64() {
                    game_state.entities.retain(|e| e.id != entity_id as u32);
                }
            }
            _ => {
                warn!("Unhandled message type: {:?}", msg.msg_type);
            }
        }
    }
}

/// System to send player input to Elixir
pub fn send_to_elixir(
    port_channels: Res<PortChannels>,
    game_state: Res<GameState>,
    keyboard: Res<ButtonInput<KeyCode>>,
) {
    let mut movement = Vec2::ZERO;

    // Capture player input
    if keyboard.pressed(KeyCode::ArrowLeft) || keyboard.pressed(KeyCode::KeyA) {
        movement.x -= 1.0;
    }
    if keyboard.pressed(KeyCode::ArrowRight) || keyboard.pressed(KeyCode::KeyD) {
        movement.x += 1.0;
    }
    if keyboard.pressed(KeyCode::ArrowUp) || keyboard.pressed(KeyCode::KeyW) {
        movement.y += 1.0;
    }
    if keyboard.pressed(KeyCode::ArrowDown) || keyboard.pressed(KeyCode::KeyS) {
        movement.y -= 1.0;
    }

    // Only send if there's actual input
    if movement.length() > 0.0 {
        let msg = ClientMessage {
            msg_type: "player_input".to_string(),
            player_id: game_state.local_player_id,
            data: serde_json::json!({
                "movement": {
                    "x": movement.x,
                    "y": movement.y
                }
            }),
        };

        if let Ok(sender) = port_channels.to_elixir.lock() {
            if sender.send(msg).is_err() {
                error!("Failed to send message to Elixir - Port closed");
            }
        }
    }

    // Handle action keys (space for infiltrator actions, etc.)
    if keyboard.just_pressed(KeyCode::Space) {
        let msg = ClientMessage {
            msg_type: "player_action".to_string(),
            player_id: game_state.local_player_id,
            data: serde_json::json!({
                "action": "interact"
            }),
        };

        if let Ok(sender) = port_channels.to_elixir.lock() {
            let _ = sender.send(msg);
        }
    }
}
