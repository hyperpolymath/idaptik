use bevy::prelude::*;
use bevy::log::info;
use bevy::gizmos::gizmos::Gizmos;
use crate::game_state::{GameState, PlayerRole};

/// Tag component for the Hacker's camera
#[derive(Component)]
pub struct HackerCamera;

/// System to set up the Hacker's top-down orthographic camera
pub fn setup_hacker_camera(mut commands: Commands, game_state: Res<GameState>) {
    if game_state.local_player_role != PlayerRole::Hacker {
        return;
    }

    // Top-down orthographic camera
    // Hacker sees the entire level from above
    commands.spawn((
        Camera2d,
        Transform::from_xyz(640.0, 360.0, 999.0),
        HackerCamera,
    ));

    info!("Hacker camera initialized - top-down view");
}

/// System to update Hacker camera position
/// Hacker can pan around the level to see strategic layout
pub fn update_hacker_camera(
    mut camera_query: Query<&mut Transform, With<HackerCamera>>,
    keyboard: Res<ButtonInput<KeyCode>>,
    time: Res<Time>,
) {
    let Ok(mut transform) = camera_query.single_mut() else {
        return;
    };

    let pan_speed = 500.0;
    let delta = time.delta_secs();

    // WASD or Arrow keys to pan camera
    if keyboard.pressed(KeyCode::KeyW) || keyboard.pressed(KeyCode::ArrowUp) {
        transform.translation.y += pan_speed * delta;
    }
    if keyboard.pressed(KeyCode::KeyS) || keyboard.pressed(KeyCode::ArrowDown) {
        transform.translation.y -= pan_speed * delta;
    }
    if keyboard.pressed(KeyCode::KeyA) || keyboard.pressed(KeyCode::ArrowLeft) {
        transform.translation.x -= pan_speed * delta;
    }
    if keyboard.pressed(KeyCode::KeyD) || keyboard.pressed(KeyCode::ArrowRight) {
        transform.translation.x += pan_speed * delta;
    }
}

/// System to render entities in top-down view
/// Hacker sees ALL entities (strategic advantage)
pub fn render_hacker_view(
    mut gizmos: Gizmos,
    game_state: Res<GameState>,
) {
    if game_state.local_player_role != PlayerRole::Hacker {
        return;
    }

    // Draw all entities from above
    for entity in &game_state.entities {
        if !entity.visible_to_hacker {
            continue;
        }

        let color = match entity.entity_type {
            crate::game_state::EntityType::Infiltrator => Color::srgb(0.0, 0.8, 0.0), // Green
            crate::game_state::EntityType::Guard => Color::srgb(0.8, 0.0, 0.0),       // Red
            crate::game_state::EntityType::Drone => Color::srgb(0.8, 0.4, 0.0),       // Orange
            crate::game_state::EntityType::Door => Color::srgb(0.4, 0.4, 0.4),        // Gray
            crate::game_state::EntityType::Wall => Color::srgb(0.2, 0.2, 0.2),        // Dark gray
            crate::game_state::EntityType::Camera => Color::srgb(0.8, 0.8, 0.0),      // Yellow
            crate::game_state::EntityType::Objective => Color::srgb(0.0, 0.0, 0.8),   // Blue
            _ => Color::WHITE,
        };

        // Draw entity as circle from above
        gizmos.circle_2d(entity.position, 20.0, color);

        // Draw velocity vector for moving entities
        if entity.velocity.length() > 0.1 {
            gizmos.arrow_2d(
                entity.position,
                entity.position + entity.velocity.normalize() * 40.0,
                color,
            );
        }
    }
}
