use bevy::prelude::*;
use serde::{Deserialize, Serialize};

/// Player role determines which camera view to use
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Component)]
pub enum PlayerRole {
    Hacker,      // Top-down strategic view
    Infiltrator, // Side-scrolling platformer view
}

/// Game entity that exists in the world
#[derive(Debug, Clone, Component, Serialize, Deserialize)]
pub struct GameEntity {
    pub id: u32,
    pub entity_type: EntityType,
    pub position: Vec2,
    pub velocity: Vec2,
    pub visible_to_hacker: bool,    // Hacker sees everything
    pub visible_to_infiltrator: bool, // Infiltrator only sees nearby
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EntityType {
    Infiltrator,
    Hacker,
    Guard,
    Drone,
    Door,
    Wall,
    Camera,
    Objective,
}

/// Shared game state synchronized from Elixir server
#[derive(Debug, Clone, Resource)]
pub struct GameState {
    pub entities: Vec<GameEntity>,
    pub local_player_id: u32,
    pub local_player_role: PlayerRole,
    pub _world_bounds: Vec2,
}

impl Default for GameState {
    fn default() -> Self {
        // Create some test entities so we can see the asymmetric views
        let test_entities = vec![
            // Player 1 - Infiltrator
            GameEntity {
                id: 1,
                entity_type: EntityType::Infiltrator,
                position: Vec2::new(400.0, 300.0),
                velocity: Vec2::ZERO,
                visible_to_hacker: true,
                visible_to_infiltrator: true,
            },
            // Player 2 - Hacker (doesn't render in their own view)
            GameEntity {
                id: 2,
                entity_type: EntityType::Hacker,
                position: Vec2::new(960.0, 540.0),
                velocity: Vec2::ZERO,
                visible_to_hacker: true,
                visible_to_infiltrator: false,
            },
            // Guard 1
            GameEntity {
                id: 3,
                entity_type: EntityType::Guard,
                position: Vec2::new(600.0, 300.0),
                velocity: Vec2::new(-50.0, 0.0),
                visible_to_hacker: true,
                visible_to_infiltrator: true,
            },
            // Guard 2
            GameEntity {
                id: 4,
                entity_type: EntityType::Guard,
                position: Vec2::new(800.0, 400.0),
                velocity: Vec2::new(50.0, 0.0),
                visible_to_hacker: true,
                visible_to_infiltrator: false, // Too far for infiltrator to see
            },
            // Door
            GameEntity {
                id: 5,
                entity_type: EntityType::Door,
                position: Vec2::new(500.0, 300.0),
                velocity: Vec2::ZERO,
                visible_to_hacker: true,
                visible_to_infiltrator: true,
            },
            // Camera (security)
            GameEntity {
                id: 6,
                entity_type: EntityType::Camera,
                position: Vec2::new(700.0, 200.0),
                velocity: Vec2::ZERO,
                visible_to_hacker: true,
                visible_to_infiltrator: false,
            },
            // Objective
            GameEntity {
                id: 7,
                entity_type: EntityType::Objective,
                position: Vec2::new(1200.0, 500.0),
                velocity: Vec2::ZERO,
                visible_to_hacker: true,
                visible_to_infiltrator: false, // Far away
            },
        ];

        Self {
            entities: test_entities,
            local_player_id: 0,
            local_player_role: PlayerRole::Infiltrator,
            _world_bounds: Vec2::new(1920.0, 1080.0),
        }
    }
}

/// Message from Elixir server via stdin (Port communication)
#[derive(Debug, Serialize, Deserialize)]
pub struct ServerMessage {
    pub msg_type: MessageType,
    pub data: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum MessageType {
    StateUpdate,
    PlayerJoined,
    PlayerLeft,
    EntitySpawned,
    EntityRemoved,
}

/// Message to Elixir server via stdout (Port communication)
#[derive(Debug, Serialize, Deserialize)]
pub struct ClientMessage {
    pub msg_type: String,
    pub player_id: u32,
    pub data: serde_json::Value,
}
