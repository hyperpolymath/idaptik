use glam::{Vec2, Vec3};
use serde::{Deserialize, Serialize};

/// Unique identifier for entities
pub type EntityId = u32;

/// Game position in 2D world (x, y) with optional height
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct Position {
    pub x: f32,
    pub y: f32,
    pub height: f32, // For multi-level stealth
}

impl Position {
    pub fn new(x: f32, y: f32) -> Self {
        Self { x, y, height: 0.0 }
    }

    pub fn with_height(x: f32, y: f32, height: f32) -> Self {
        Self { x, y, height }
    }

    pub fn distance_to(&self, other: &Position) -> f32 {
        let dx = self.x - other.x;
        let dy = self.y - other.y;
        let dz = self.height - other.height;
        (dx * dx + dy * dy + dz * dz).sqrt()
    }

    pub fn distance_2d(&self, other: &Position) -> f32 {
        let dx = self.x - other.x;
        let dy = self.y - other.y;
        (dx * dx + dy * dy).sqrt()
    }

    pub fn to_vec2(&self) -> Vec2 {
        Vec2::new(self.x, self.y)
    }

    pub fn to_vec3(&self) -> Vec3 {
        Vec3::new(self.x, self.y, self.height)
    }
}

/// Entity type classification
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EntityType {
    Player,
    Guard,
    Camera,
    Door,
    LightSource,
    SoundEmitter,
    CoverObject,
}

/// Movement stance affects visibility and noise
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Stance {
    Standing,
    Crouching,
    Prone,
}

/// Player and NPC states
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ActorState {
    Idle,
    Walking,
    Running,
    Hiding,
    Investigating,
    Alerted,
    Hunting,
}

/// Core entity data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Entity {
    pub id: EntityId,
    pub entity_type: EntityType,
    pub position: Position,
    pub rotation: f32, // Radians
    pub velocity: Vec2,
    pub stance: Stance,
    pub state: ActorState,
    
    // Visibility
    pub visible: bool,
    pub visibility_radius: f32,
    pub field_of_view: f32, // Radians (for guards/cameras)
    
    // Stealth attributes
    pub noise_level: f32,      // How much noise this entity makes
    pub detection_level: f32,  // 0.0 = undetected, 1.0 = fully detected
    pub light_exposure: f32,   // 0.0 = in shadow, 1.0 = fully lit
    
    // Attributes
    pub speed: f32,
    pub health: f32,
}

impl Entity {
    pub fn new_player(id: EntityId, position: Position) -> Self {
        Self {
            id,
            entity_type: EntityType::Player,
            position,
            rotation: 0.0,
            velocity: Vec2::ZERO,
            stance: Stance::Standing,
            state: ActorState::Idle,
            visible: true,
            visibility_radius: 15.0,
            field_of_view: std::f32::consts::PI * 2.0, // 360 degrees
            noise_level: 0.0,
            detection_level: 0.0,
            light_exposure: 0.5,
            speed: 5.0,
            health: 100.0,
        }
    }

    pub fn new_guard(id: EntityId, position: Position) -> Self {
        Self {
            id,
            entity_type: EntityType::Guard,
            position,
            rotation: 0.0,
            velocity: Vec2::ZERO,
            stance: Stance::Standing,
            state: ActorState::Idle,
            visible: true,
            visibility_radius: 20.0,
            field_of_view: std::f32::consts::PI * 0.8, // ~144 degrees
            noise_level: 0.0,
            detection_level: 0.0,
            light_exposure: 1.0,
            speed: 4.0,
            health: 100.0,
        }
    }

    /// Get the direction vector this entity is facing
    pub fn facing_direction(&self) -> Vec2 {
        Vec2::new(self.rotation.cos(), self.rotation.sin())
    }

    /// Check if this entity is facing towards a position
    pub fn is_facing(&self, target: &Position) -> bool {
        let to_target = (target.to_vec2() - self.position.to_vec2()).normalize();
        let facing = self.facing_direction();
        let angle = to_target.dot(facing).acos();
        angle < self.field_of_view / 2.0
    }
}

/// World obstacles and cover
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Obstacle {
    pub position: Position,
    pub radius: f32,
    pub blocks_vision: bool,
    pub blocks_sound: bool,
    pub provides_cover: bool,
}

/// Light source in the world
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LightSource {
    pub position: Position,
    pub radius: f32,
    pub intensity: f32, // 0.0 to 1.0
}

/// Game world state
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct World {
    pub entities: Vec<Entity>,
    pub obstacles: Vec<Obstacle>,
    pub lights: Vec<LightSource>,
    pub width: f32,
    pub height: f32,
    pub ambient_light: f32,
}

impl World {
    pub fn new(width: f32, height: f32) -> Self {
        Self {
            entities: Vec::new(),
            obstacles: Vec::new(),
            lights: Vec::new(),
            width,
            height,
            ambient_light: 0.3,
        }
    }

    pub fn add_entity(&mut self, entity: Entity) -> EntityId {
        let id = entity.id;
        self.entities.push(entity);
        id
    }

    pub fn get_entity(&self, id: EntityId) -> Option<&Entity> {
        self.entities.iter().find(|e| e.id == id)
    }

    pub fn get_entity_mut(&mut self, id: EntityId) -> Option<&mut Entity> {
        self.entities.iter_mut().find(|e| e.id == id)
    }

    pub fn remove_entity(&mut self, id: EntityId) -> bool {
        if let Some(pos) = self.entities.iter().position(|e| e.id == id) {
            self.entities.remove(pos);
            true
        } else {
            false
        }
    }
}
