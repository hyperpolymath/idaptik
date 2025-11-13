use crate::game::types::*;
use crate::stealth::detection::*;
use glam::Vec2;
use serde::{Deserialize, Serialize};

/// Game system that updates all game logic
pub struct GameSystem {
    pub world: World,
    next_entity_id: EntityId,
    pub time: f32,
}

/// Player input commands
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct PlayerInput {
    pub move_x: f32,
    pub move_y: f32,
    pub sprint: bool,
    pub crouch: bool,
    pub prone: bool,
}

impl Default for PlayerInput {
    fn default() -> Self {
        Self {
            move_x: 0.0,
            move_y: 0.0,
            sprint: false,
            crouch: false,
            prone: false,
        }
    }
}

/// Game events that can occur
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum GameEvent {
    PlayerDetected { player_id: EntityId, guard_id: EntityId, level: f32 },
    PlayerHidden { player_id: EntityId },
    GuardAlerted { guard_id: EntityId, position: Position },
    ObjectiveComplete { player_id: EntityId },
}

impl GameSystem {
    pub fn new(width: f32, height: f32) -> Self {
        Self {
            world: World::new(width, height),
            next_entity_id: 1,
            time: 0.0,
        }
    }

    /// Generate next unique entity ID
    fn next_id(&mut self) -> EntityId {
        let id = self.next_entity_id;
        self.next_entity_id += 1;
        id
    }

    /// Spawn a player entity
    pub fn spawn_player(&mut self, x: f32, y: f32) -> EntityId {
        let id = self.next_id();
        let entity = Entity::new_player(id, Position::new(x, y));
        self.world.add_entity(entity)
    }

    /// Spawn a guard entity
    pub fn spawn_guard(&mut self, x: f32, y: f32) -> EntityId {
        let id = self.next_id();
        let entity = Entity::new_guard(id, Position::new(x, y));
        self.world.add_entity(entity)
    }

    /// Add an obstacle to the world
    pub fn add_obstacle(&mut self, x: f32, y: f32, radius: f32) {
        self.world.obstacles.push(Obstacle {
            position: Position::new(x, y),
            radius,
            blocks_vision: true,
            blocks_sound: true,
            provides_cover: true,
        });
    }

    /// Add a light source
    pub fn add_light(&mut self, x: f32, y: f32, radius: f32, intensity: f32) {
        self.world.lights.push(LightSource {
            position: Position::new(x, y),
            radius,
            intensity,
        });
    }

    /// Main game update loop
    pub fn update(&mut self, delta_time: f32) -> Vec<GameEvent> {
        self.time += delta_time;
        let mut events = Vec::new();

        // Update light exposure for all entities
        self.update_lighting();

        // Update noise levels
        self.update_noise();

        // Update movement physics
        self.update_physics(delta_time);

        // Update detection and AI
        events.extend(self.update_detection_and_ai(delta_time));

        events
    }

    /// Apply player input to move a player entity
    pub fn apply_player_input(&mut self, player_id: EntityId, input: PlayerInput) {
        let Some(player) = self.world.get_entity_mut(player_id) else {
            return;
        };

        if player.entity_type != EntityType::Player {
            return;
        }

        // Update stance
        player.stance = if input.prone {
            Stance::Prone
        } else if input.crouch {
            Stance::Crouching
        } else {
            Stance::Standing
        };

        // Update state based on movement
        let is_moving = input.move_x.abs() > 0.01 || input.move_y.abs() > 0.01;
        player.state = if !is_moving {
            ActorState::Idle
        } else if input.sprint {
            ActorState::Running
        } else {
            ActorState::Walking
        };

        // Calculate movement speed based on stance and sprint
        let base_speed = player.speed;
        let speed = match player.stance {
            Stance::Standing => if input.sprint { base_speed * 2.0 } else { base_speed },
            Stance::Crouching => base_speed * 0.6,
            Stance::Prone => base_speed * 0.3,
        };

        // Apply movement
        if is_moving {
            let move_vec = Vec2::new(input.move_x, input.move_y).normalize();
            player.velocity = move_vec * speed;
            
            // Update rotation to face movement direction
            player.rotation = move_vec.y.atan2(move_vec.x);
        } else {
            player.velocity = Vec2::ZERO;
        }
    }

    fn update_lighting(&mut self) {
        // Calculate light exposure for each entity
        for i in 0..self.world.entities.len() {
            let entity = &self.world.entities[i];
            let light_exposure = calculate_light_exposure(entity, &self.world);
            self.world.entities[i].light_exposure = light_exposure;
        }
    }

    fn update_noise(&mut self) {
        // Calculate noise from all moving entities
        let noise_sources: Vec<(Position, f32)> = self.world.entities.iter()
            .map(|e| (e.position, calculate_movement_noise(e)))
            .collect();

        // Update noise awareness for all entities
        for i in 0..self.world.entities.len() {
            let entity_pos = self.world.entities[i].position;
            let noise_level = calculate_noise_at_position(
                &entity_pos,
                &noise_sources,
                &self.world.obstacles
            );
            self.world.entities[i].noise_level = noise_level;
        }
    }

    fn update_physics(&mut self, delta_time: f32) {
        for entity in &mut self.world.entities {
            // Update position based on velocity
            let delta_pos = entity.velocity * delta_time;
            entity.position.x += delta_pos.x;
            entity.position.y += delta_pos.y;

            // Keep within world bounds
            entity.position.x = entity.position.x.clamp(0.0, self.world.width);
            entity.position.y = entity.position.y.clamp(0.0, self.world.height);

            // Simple collision with obstacles
            for obstacle in &self.world.obstacles {
                let dist = entity.position.distance_2d(&obstacle.position);
                if dist < obstacle.radius + 0.5 {
                    // Push entity away from obstacle
                    let push_dir = (entity.position.to_vec2() - obstacle.position.to_vec2()).normalize();
                    let push_amount = obstacle.radius + 0.5 - dist;
                    entity.position.x += push_dir.x * push_amount;
                    entity.position.y += push_dir.y * push_amount;
                }
            }
        }
    }

    fn update_detection_and_ai(&mut self, delta_time: f32) -> Vec<GameEvent> {
        let mut events = Vec::new();

        // Find all players and guards
        let players: Vec<EntityId> = self.world.entities.iter()
            .filter(|e| e.entity_type == EntityType::Player)
            .map(|e| e.id)
            .collect();

        let guards: Vec<EntityId> = self.world.entities.iter()
            .filter(|e| e.entity_type == EntityType::Guard)
            .map(|e| e.id)
            .collect();

        // Guards detect players
        for &guard_id in &guards {
            for &player_id in &players {
                let guard = self.world.get_entity(guard_id).unwrap().clone();
                let player = self.world.get_entity(player_id).unwrap().clone();

                let visibility = calculate_visibility(&guard, &player, &self.world);

                // Update player detection level
                let player_mut = self.world.get_entity_mut(player_id).unwrap();
                let old_detection = player_mut.detection_level;
                update_detection(player_mut, visibility, delta_time);
                let new_detection = player_mut.detection_level;

                // Generate detection events
                if old_detection < 0.9 && new_detection >= 0.9 {
                    events.push(GameEvent::PlayerDetected {
                        player_id,
                        guard_id,
                        level: new_detection,
                    });

                    // Alert the guard
                    let guard_mut = self.world.get_entity_mut(guard_id).unwrap();
                    guard_mut.state = ActorState::Alerted;
                } else if old_detection > 0.1 && new_detection <= 0.1 {
                    events.push(GameEvent::PlayerHidden { player_id });
                }
            }
        }

        events
    }

    /// Serialize game state for network sync
    pub fn serialize_state(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string(&self.world)
    }

    /// Deserialize and apply game state from network
    pub fn deserialize_state(&mut self, state_json: &str) -> Result<(), serde_json::Error> {
        self.world = serde_json::from_str(state_json)?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_spawn_entities() {
        let mut game = GameSystem::new(100.0, 100.0);
        let player_id = game.spawn_player(10.0, 10.0);
        let guard_id = game.spawn_guard(50.0, 50.0);

        assert_eq!(game.world.entities.len(), 2);
        assert!(game.world.get_entity(player_id).is_some());
        assert!(game.world.get_entity(guard_id).is_some());
    }

    #[test]
    fn test_player_input() {
        let mut game = GameSystem::new(100.0, 100.0);
        let player_id = game.spawn_player(10.0, 10.0);

        let input = PlayerInput {
            move_x: 1.0,
            move_y: 0.0,
            sprint: false,
            crouch: true,
            prone: false,
        };

        game.apply_player_input(player_id, input);
        
        let player = game.world.get_entity(player_id).unwrap();
        assert_eq!(player.stance, Stance::Crouching);
        assert!(player.velocity.length() > 0.0);
    }

    #[test]
    fn test_update_loop() {
        let mut game = GameSystem::new(100.0, 100.0);
        game.spawn_player(10.0, 10.0);
        game.spawn_guard(50.0, 50.0);

        let events = game.update(0.016); // ~60 FPS
        assert!(events.is_empty()); // No immediate detection
    }
}
