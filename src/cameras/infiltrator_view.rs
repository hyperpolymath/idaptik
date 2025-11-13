use bevy::prelude::*;
use bevy::log::info;
use bevy::gizmos::gizmos::Gizmos;
use crate::game_state::{GameState, PlayerRole, EntityType};

/// Tag component for the Infiltrator's camera
#[derive(Component)]
pub struct InfiltratorCamera;

/// System to set up the Infiltrator's side-scrolling camera
pub fn setup_infiltrator_camera(mut commands: Commands, game_state: Res<GameState>) {
    if game_state.local_player_role != PlayerRole::Infiltrator {
        return;
    }

    // Find infiltrator starting position by entity type, not player_id
    let player_pos = game_state.entities
        .iter()
        .find(|e| matches!(e.entity_type, EntityType::Infiltrator))
        .map(|e| e.position)
        .unwrap_or(Vec2::new(400.0, 300.0));

    // Side-scrolling camera follows the player
    commands.spawn((
        Camera2d,
        Transform::from_xyz(player_pos.x, player_pos.y, 999.0),
        InfiltratorCamera,
    ));

    info!("Infiltrator camera initialized - side-scrolling view");
}

/// System to update Infiltrator camera position
/// Camera follows the infiltrator smoothly
pub fn update_infiltrator_camera(
    mut camera_query: Query<&mut Transform, With<InfiltratorCamera>>,
    game_state: Res<GameState>,
    time: Res<Time>,
) {
    let Ok(mut camera_transform) = camera_query.single_mut() else {
        return;
    };

    // Find the local player (infiltrator) by entity type
    let Some(player) = game_state.entities.iter().find(|e| matches!(e.entity_type, EntityType::Infiltrator)) else {
        return;
    };

    // Smooth camera follow using lerp
    let lerp_factor = 5.0 * time.delta_secs();
    let target_x = player.position.x;
    let target_y = player.position.y;

    camera_transform.translation.x = camera_transform.translation.x.lerp(target_x, lerp_factor);
    camera_transform.translation.y = camera_transform.translation.y.lerp(target_y, lerp_factor);
}

/// System to render entities in side-scrolling view
/// Infiltrator only sees entities within their limited field of view
pub fn render_infiltrator_view(
    mut gizmos: Gizmos,
    game_state: Res<GameState>,
) {
    if game_state.local_player_role != PlayerRole::Infiltrator {
        return;
    }

    // Find the local player position by entity type to determine visibility
    let player_pos = game_state.entities
        .iter()
        .find(|e| matches!(e.entity_type, EntityType::Infiltrator))
        .map(|e| e.position)
        .unwrap_or(Vec2::ZERO);

    let visibility_radius = 300.0; // Infiltrator's sight range

    // Draw entities that are visible to infiltrator
    for entity in &game_state.entities {
        if !entity.visible_to_infiltrator {
            continue;
        }

        // Check if entity is within visibility range
        let distance = player_pos.distance(entity.position);
        if distance > visibility_radius {
            continue; // Too far to see
        }

        // Fade out entities at edge of vision
        let visibility_factor = 1.0 - (distance / visibility_radius).clamp(0.0, 1.0);

        let color = match entity.entity_type {
            EntityType::Guard => Color::srgba(0.8, 0.0, 0.0, visibility_factor),       // Red
            EntityType::Drone => Color::srgba(0.8, 0.4, 0.0, visibility_factor),       // Orange
            EntityType::Door => Color::srgba(0.4, 0.4, 0.4, visibility_factor),        // Gray
            EntityType::Wall => Color::srgba(0.2, 0.2, 0.2, visibility_factor),        // Dark gray
            EntityType::Camera => Color::srgba(0.8, 0.8, 0.0, visibility_factor),      // Yellow
            EntityType::Objective => Color::srgba(0.0, 0.0, 0.8, visibility_factor),   // Blue
            _ => Color::srgba(1.0, 1.0, 1.0, visibility_factor),
        };

        // Draw entity as sprite/shape from side view
        // For now using simple shapes - replace with proper sprites later
        match entity.entity_type {
            EntityType::Guard | EntityType::Drone => {
                // Draw as rectangle (placeholder for character sprite)
                gizmos.rect_2d(entity.position, Vec2::new(40.0, 60.0), color);
            }
            EntityType::Door => {
                // Draw as tall rectangle
                gizmos.rect_2d(entity.position, Vec2::new(20.0, 100.0), color);
            }
            EntityType::Wall => {
                // Draw as solid rectangle
                gizmos.rect_2d(entity.position, Vec2::new(40.0, 40.0), color);
            }
            _ => {
                // Draw as circle for other entities
                gizmos.circle_2d(entity.position, 20.0, color);
            }
        }
    }

    // Optional: Uncomment to see visibility radius (debug)
    // gizmos.circle_2d(player_pos, visibility_radius, Color::srgba(1.0, 1.0, 1.0, 0.1));
}
