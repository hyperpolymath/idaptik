use bevy::prelude::*;
use bevy::log::info;

mod cameras;
mod game_state;
mod port_communication;

use cameras::*;
use game_state::*;
use port_communication::*;

fn main() {
    // Read player role from command line args
    // Elixir will spawn with: ./idaptik-core --role hacker --player-id 1
    let args: Vec<String> = std::env::args().collect();
    let role = parse_role(&args);
    let player_id = parse_player_id(&args);

    info!("Starting IDApTIK Core - Role: {:?}, Player ID: {}", role, player_id);

    // Initialize Port communication
    let port_channels = init_port_communication();

    App::new()
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                title: format!("IDApTIK - {:?} View", role),
                resolution: (1280, 720).into(),
                ..default()
            }),
            ..default()
        }))
        // Insert game state resource
        .insert_resource(GameState {
            local_player_role: role,
            local_player_id: player_id,
            ..default()
        })
        // Insert Port communication channels
        .insert_resource(port_channels)
        // Setup systems - run once at startup
        .add_systems(Startup, (
            setup_hacker_camera,
            setup_infiltrator_camera,
        ))
        // Update systems - run every frame
        .add_systems(Update, (
            // Port communication
            receive_from_elixir,
            send_to_elixir,
            // Camera updates
            update_hacker_camera,
            update_infiltrator_camera,
        ))
        .add_systems(Update, (
            // Rendering
            render_hacker_view,
            render_infiltrator_view,
        ))
        .run();
}

/// Parse player role from command line arguments
fn parse_role(args: &[String]) -> PlayerRole {
    for i in 0..args.len() {
        if args[i] == "--role" && i + 1 < args.len() {
            return match args[i + 1].to_lowercase().as_str() {
                "hacker" => PlayerRole::Hacker,
                "infiltrator" => PlayerRole::Infiltrator,
                _ => {
                    eprintln!("Unknown role '{}', defaulting to Infiltrator", args[i + 1]);
                    PlayerRole::Infiltrator
                }
            };
        }
    }
    
    eprintln!("No --role specified, defaulting to Infiltrator");
    PlayerRole::Infiltrator
}

/// Parse player ID from command line arguments
fn parse_player_id(args: &[String]) -> u32 {
    for i in 0..args.len() {
        if args[i] == "--player-id" && i + 1 < args.len() {
            return args[i + 1].parse().unwrap_or_else(|_| {
                eprintln!("Invalid player ID '{}', defaulting to 0", args[i + 1]);
                0
            });
        }
    }
    
    eprintln!("No --player-id specified, defaulting to 0");
    0
}
