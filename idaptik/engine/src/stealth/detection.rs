use crate::game::types::*;
use glam::Vec2;

/// Calculate line-of-sight between two positions
pub fn has_line_of_sight(
    from: &Position,
    to: &Position,
    obstacles: &[Obstacle],
) -> bool {
    let from_vec = from.to_vec2();
    let to_vec = to.to_vec2();
    let direction = (to_vec - from_vec).normalize();
    let distance = from.distance_2d(to);

    // Check if any obstacle blocks the line
    for obstacle in obstacles {
        if !obstacle.blocks_vision {
            continue;
        }

        let obstacle_pos = obstacle.position.to_vec2();
        let to_obstacle = obstacle_pos - from_vec;
        
        // Project obstacle onto the line
        let projection = to_obstacle.dot(direction);
        
        // Skip if obstacle is behind or beyond target
        if projection < 0.0 || projection > distance {
            continue;
        }

        // Check distance from line to obstacle center
        let closest_point = from_vec + direction * projection;
        let dist_to_line = (obstacle_pos - closest_point).length();

        if dist_to_line < obstacle.radius {
            return false; // Blocked!
        }
    }

    true
}

/// Calculate how visible an entity is from an observer's perspective
pub fn calculate_visibility(
    observer: &Entity,
    target: &Entity,
    world: &World,
) -> f32 {
    // Distance factor (closer = more visible)
    let distance = observer.position.distance_2d(&target.position);
    if distance > observer.visibility_radius {
        return 0.0; // Too far away
    }
    
    let distance_factor = 1.0 - (distance / observer.visibility_radius);

    // Check if observer is facing target
    if !observer.is_facing(&target.position) {
        return 0.0; // Not in field of view
    }

    // Check line of sight
    if !has_line_of_sight(&observer.position, &target.position, &world.obstacles) {
        return 0.0; // Blocked by obstacle
    }

    // Stance factor (prone is harder to see)
    let stance_factor = match target.stance {
        Stance::Standing => 1.0,
        Stance::Crouching => 0.6,
        Stance::Prone => 0.3,
    };

    // Lighting factor
    let light_factor = target.light_exposure;

    // Movement factor (moving entities are easier to spot)
    let movement_factor = if target.velocity.length() > 0.1 {
        1.2 // Moving makes you more visible
    } else {
        1.0
    };

    // Combine all factors
    let visibility = distance_factor * stance_factor * light_factor * movement_factor;
    visibility.clamp(0.0, 1.0)
}

/// Calculate light exposure for an entity
pub fn calculate_light_exposure(
    entity: &Entity,
    world: &World,
) -> f32 {
    let mut total_light = world.ambient_light;

    for light in &world.lights {
        let distance = entity.position.distance_to(&light.position);
        
        if distance > light.radius {
            continue; // Out of range
        }

        // Check if light is blocked by obstacles
        if !has_line_of_sight(&light.position, &entity.position, &world.obstacles) {
            continue; // In shadow
        }

        // Inverse square law with linear falloff for gameplay
        let light_contribution = light.intensity * (1.0 - distance / light.radius);
        total_light += light_contribution;
    }

    total_light.clamp(0.0, 1.0)
}

/// Calculate noise propagation
pub fn calculate_noise_at_position(
    position: &Position,
    noise_sources: &[(Position, f32)], // (source position, noise level)
    obstacles: &[Obstacle],
) -> f32 {
    let mut total_noise = 0.0;

    for (source_pos, noise_level) in noise_sources {
        let distance = position.distance_2d(source_pos);
        
        // Sound attenuates with distance
        let base_attenuation = (1.0 - (distance / 30.0).min(1.0)) * noise_level;
        
        // Count blocking obstacles
        let mut blocking_factor = 1.0;
        for obstacle in obstacles {
            if !obstacle.blocks_sound {
                continue;
            }

            // Simple check: is obstacle between source and listener?
            let to_obstacle = obstacle.position.to_vec2() - source_pos.to_vec2();
            let to_listener = position.to_vec2() - source_pos.to_vec2();
            
            if to_obstacle.dot(to_listener) > 0.0 {
                let obstacle_dist = source_pos.distance_2d(&obstacle.position);
                let listener_dist = source_pos.distance_2d(position);
                
                if obstacle_dist < listener_dist {
                    blocking_factor *= 0.7; // Each obstacle reduces sound by 30%
                }
            }
        }

        total_noise += base_attenuation * blocking_factor;
    }

    total_noise.clamp(0.0, 1.0)
}

/// Calculate noise level based on movement and stance
pub fn calculate_movement_noise(entity: &Entity) -> f32 {
    let speed = entity.velocity.length();
    
    if speed < 0.1 {
        return 0.0; // Not moving
    }

    // Base noise from movement
    let base_noise = speed / entity.speed;

    // Stance modifier
    let stance_modifier = match entity.stance {
        Stance::Standing => 1.0,
        Stance::Crouching => 0.5,
        Stance::Prone => 0.2,
    };

    // Running makes more noise
    let movement_modifier = if entity.state == ActorState::Running {
        2.0
    } else {
        1.0
    };

    (base_noise * stance_modifier * movement_modifier).clamp(0.0, 1.0)
}

/// Check if entity is in cover relative to an observer
pub fn is_in_cover(
    entity: &Entity,
    observer: &Entity,
    world: &World,
) -> bool {
    let direction = (entity.position.to_vec2() - observer.position.to_vec2()).normalize();
    
    for obstacle in &world.obstacles {
        if !obstacle.provides_cover {
            continue;
        }

        // Check if obstacle is between observer and entity
        let to_obstacle = obstacle.position.to_vec2() - observer.position.to_vec2();
        let to_entity = entity.position.to_vec2() - observer.position.to_vec2();
        
        if to_obstacle.dot(direction) > 0.0 && to_obstacle.length() < to_entity.length() {
            // Check if entity is close enough to obstacle to use it as cover
            let dist_to_obstacle = entity.position.distance_2d(&obstacle.position);
            if dist_to_obstacle < obstacle.radius + 1.0 {
                return true;
            }
        }
    }

    false
}

/// Update detection level based on visibility
pub fn update_detection(
    target: &mut Entity,
    visibility: f32,
    delta_time: f32,
) {
    if visibility > 0.1 {
        // Being seen - detection increases
        let detection_rate = visibility * 0.5; // Takes ~2 seconds to fully detect in ideal conditions
        target.detection_level += detection_rate * delta_time;
    } else {
        // Not visible - detection decreases slowly
        target.detection_level -= 0.2 * delta_time; // Takes 5 seconds to lose detection
    }

    target.detection_level = target.detection_level.clamp(0.0, 1.0);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_line_of_sight_clear() {
        let from = Position::new(0.0, 0.0);
        let to = Position::new(10.0, 0.0);
        let obstacles = vec![];
        
        assert!(has_line_of_sight(&from, &to, &obstacles));
    }

    #[test]
    fn test_line_of_sight_blocked() {
        let from = Position::new(0.0, 0.0);
        let to = Position::new(10.0, 0.0);
        let obstacles = vec![
            Obstacle {
                position: Position::new(5.0, 0.0),
                radius: 2.0,
                blocks_vision: true,
                blocks_sound: true,
                provides_cover: true,
            }
        ];
        
        assert!(!has_line_of_sight(&from, &to, &obstacles));
    }

    #[test]
    fn test_movement_noise() {
        let mut entity = Entity::new_player(1, Position::new(0.0, 0.0));
        entity.velocity = Vec2::new(5.0, 0.0);
        entity.stance = Stance::Standing;
        
        let noise = calculate_movement_noise(&entity);
        assert!(noise > 0.0);
        
        entity.stance = Stance::Crouching;
        let crouch_noise = calculate_movement_noise(&entity);
        assert!(crouch_noise < noise);
    }
}
