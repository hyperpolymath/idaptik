# IDApTIK - Multiplayer Stealth Game

A real-time multiplayer stealth game with:
- **Elixir Backend**: Scalable multiplayer server (Phoenix Channels)
- **Rust Engine**: High-performance game logic compiled to WASM
- **ReScript Frontend**: Type-safe UI and game client

## Architecture

```
┌─────────────────────────────────────────┐
│         ReScript Frontend               │
│  (UI, Input, Rendering, Networking)     │
└──────────────┬──────────────────────────┘
               │
               ├─► Rust Engine (WASM)
               │   (Game Logic, Physics, AI)
               │
               └─► Elixir Backend (Phoenix)
                   (State Sync, Matchmaking)
```

## Tech Stack

- **Backend**: Elixir + Phoenix + Phoenix Channels
- **Engine**: Rust → WASM (game logic)
- **Frontend**: ReScript → JavaScript (UI/rendering)
- **Build**: Podman for containerization
- **Repo**: GitLab

## Directory Structure

```
idaptik/
├── backend/          # Elixir Phoenix app (already built)
├── engine/           # Rust game engine
│   ├── src/
│   │   ├── lib.rs
│   │   ├── game/
│   │   ├── stealth/
│   │   └── wasm/
│   └── Cargo.toml
├── frontend/         # ReScript application
│   ├── src/
│   │   ├── Game.res
│   │   ├── Network.res
│   │   └── UI.res
│   └── package.json
└── compose.yml       # Podman compose for local dev
```

## Quick Start

```bash
# Build Rust engine to WASM
cd engine && cargo build --target wasm32-unknown-unknown --release

# Install frontend deps and build
cd frontend && npm install && npm run build

# Run full stack
podman-compose up
```
