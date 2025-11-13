# IDApTIK Development Guide

## What We've Built

### ✅ Rust Game Engine (`engine/`)
A complete stealth game engine with:
- **Core Game Types** (`game/types.rs`): Entities, positions, world state
- **Stealth Mechanics** (`stealth/detection.rs`): 
  - Line-of-sight calculations
  - Sound propagation
  - Light exposure tracking
  - Cover detection
  - Detection accumulation
- **Game System** (`game/system.rs`):
  - Entity spawning (players, guards)
  - Physics updates
  - AI behavior
  - Event generation
- **WASM Bindings** (`wasm/bindings.rs`): JavaScript interop

**Features:**
- 🎯 Advanced visibility system with FOV and obstacles
- 🔊 Realistic sound propagation with occlusion
- 💡 Dynamic lighting with shadows
- 🏃 Multiple movement stances (standing, crouching, prone)
- 🎮 Detection system with accumulation
- 📦 Compiles to WASM for browser execution

### ✅ ReScript Frontend (`frontend/src/`)
Type-safe frontend with:
- **WasmEngine.res**: Bindings to Rust WASM engine
- **Network.res**: Phoenix Channel client for multiplayer
- **Renderer.res**: Canvas 2D rendering
- **Game.res**: Main game coordinator
- **Main.res**: Entry point and initialization

**Features:**
- 🎨 Real-time Canvas rendering
- ⌨️ Keyboard input handling (WASD, arrow keys, modifiers)
- 🌐 Phoenix Channel integration (ready for your Elixir backend)
- 🎮 Game loop with delta time
- 📊 Live detection visualization

### 🔄 Integration Points
Your **Elixir backend** connects via:
- Phoenix Channels on `ws://localhost:4000/socket`
- Room-based multiplayer (`room:roomId`)
- Events: `player_input`, `state_update`, `player_joined`, `player_left`

## Project Structure

```
idaptik/
├── engine/                 # Rust game engine
│   ├── src/
│   │   ├── game/          # Core game logic
│   │   │   ├── types.rs   # Entity types and world state
│   │   │   └── system.rs  # Game loop and updates
│   │   ├── stealth/       # Stealth mechanics
│   │   │   └── detection.rs
│   │   ├── wasm/          # WASM bindings
│   │   │   └── bindings.rs
│   │   └── lib.rs
│   └── Cargo.toml
│
├── frontend/              # ReScript frontend
│   ├── src/
│   │   ├── WasmEngine.res    # Rust engine bindings
│   │   ├── Network.res       # Phoenix Channels
│   │   ├── Renderer.res      # Canvas rendering
│   │   ├── Game.res          # Game coordinator
│   │   └── Main.res          # Entry point
│   ├── public/
│   │   └── index.html
│   ├── package.json
│   ├── bsconfig.json
│   └── vite.config.js
│
├── backend/               # Your Elixir Phoenix app (existing)
│   └── ...
│
├── build-wasm.sh         # Build Rust to WASM
├── compose.yml           # Podman compose config
└── README.md
```

## Development Workflow

### 1. Build the Rust Engine

```bash
./build-wasm.sh
```

This compiles the Rust engine to WASM and copies it to the frontend.

### 2. Install Frontend Dependencies

```bash
cd frontend
npm install
```

### 3. Build ReScript

```bash
npm run res:build
# Or watch mode:
npm run res:dev
```

### 4. Start Development Server

**Option A: Full Stack with Podman**
```bash
podman-compose up
```

This starts:
- Backend (Elixir) on `localhost:4000`
- Frontend (Vite) on `localhost:3000`
- Database (PostgreSQL) on `localhost:5432`

**Option B: Frontend Only**
```bash
cd frontend
npm run dev
```

Then start your Elixir backend separately:
```bash
cd backend
mix phx.server
```

### 5. Access the Game

Open `http://localhost:3000` in your browser.

## Controls

| Key | Action |
|-----|--------|
| <kbd>W A S D</kbd> or <kbd>Arrow Keys</kbd> | Move |
| <kbd>Shift</kbd> | Sprint (louder, more visible) |
| <kbd>Ctrl</kbd> | Crouch (quieter, less visible) |
| <kbd>Z</kbd> | Prone (quietest, hardest to see) |

## Game Mechanics

### Stealth System

1. **Visibility**: Guards can see you based on:
   - Distance (closer = more visible)
   - Field of View (must be in their cone)
   - Line of Sight (obstacles block vision)
   - Lighting (darker areas = less visible)
   - Stance (prone < crouching < standing)
   - Movement (moving = more visible)

2. **Detection**: 
   - Detection accumulates when visible (0-1.0 scale)
   - Red bar appears above player when detected
   - Guards become "alerted" at high detection
   - Detection decays slowly when hidden

3. **Sound**:
   - Movement generates noise
   - Sprint is loudest, prone is quietest
   - Sound propagates through world
   - Obstacles reduce sound transmission

4. **Light**:
   - Stay in shadows to avoid detection
   - Ambient light + dynamic light sources
   - Light exposure affects visibility

## Multiplayer Integration

### Elixir Backend Events

Your Phoenix Channel should handle:

```elixir
# Incoming from client
"player_input" => %{move_x, move_y, timestamp}
"state_sync" => %{state: json_state}

# Outgoing to clients
"state_update" => %{entities: [...], timestamp}
"player_joined" => %{player_id, position}
"player_left" => %{player_id}
```

### Network.res Usage

```rescript
// Connect to room
let network = Network.create(
  ~endpoint="ws://localhost:4000/socket",
  ~onStateChange=state => Console.log(state)
)

network->Network.joinRoom(
  ~roomId="game-123",
  ~playerId=1,
  ~onMessage=msg => {
    // Handle state updates
  }
)

// Send input
network->Network.sendInput(~input={x: 1.0, y: 0.0, height: 0.0})
```

## Testing

### Rust Tests
```bash
cd engine
cargo test
```

### Frontend (Manual)
1. Start dev server
2. Open browser console
3. Check for errors
4. Test controls and rendering

## Next Steps

### Core Game Development

1. **AI Improvements**:
   - Add patrol routes
   - Implement guard search behavior
   - Add guard communication

2. **Level Design**:
   - Create level editor
   - Add objectives (items to steal, areas to reach)
   - Multiple level support

3. **Gameplay Features**:
   - Inventory system
   - Tools (lockpicks, distractions)
   - Guard alert states
   - Win/lose conditions

4. **Multiplayer**:
   - Synchronize state with Elixir backend
   - Handle latency/prediction
   - Add co-op gameplay modes

5. **Polish**:
   - Sound effects
   - Better graphics/sprites
   - UI improvements
   - Tutorial

### Performance

- Current target: 60 FPS
- WASM engine is very fast
- Canvas rendering is lightweight
- Network sync rate configurable

## Debugging

### Browser Console
```javascript
// Game instance is exposed globally
window.game

// Check engine state
window.game.engine.getState()

// View network connection
window.game.network
```

### Common Issues

1. **WASM not loading**: Run `./build-wasm.sh` first
2. **ReScript errors**: Run `npm run res:clean && npm run res:build`
3. **Network connection fails**: Check Elixir backend is running on `:4000`
4. **Canvas not rendering**: Check browser console for errors

## Architecture Decisions

### Why Rust + WASM?
- **Performance**: Native-speed game logic in browser
- **Type Safety**: Compile-time guarantees
- **Portability**: Works anywhere WASM runs
- **No GC**: Predictable performance

### Why ReScript?
- **Type Safety**: Full type inference
- **Fast Compilation**: Sub-second builds
- **Great Interop**: Easy JS/WASM integration
- **Functional**: Clean, maintainable code

### Why Elixir Backend?
- **Scalability**: Built for massive concurrency
- **Real-time**: Phoenix Channels for WebSocket
- **Fault Tolerance**: OTP supervision
- **Your Choice!** (You already built it)

## Contributing

This is your project! The foundation is solid. Now you can:
- Add features to the Rust engine
- Improve the ReScript UI
- Enhance the multiplayer sync
- Build levels and content

The architecture is clean and modular - each part can be developed independently.

---

**Built with:**
- 🦀 Rust + WASM
- 🔷 ReScript
- 🧪 Elixir + Phoenix
- 🐳 Podman
- 🦊 GitLab (your preference!)

Ready to continue developing! 🎮
