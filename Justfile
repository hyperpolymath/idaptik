# JUSTFILE - Primary Task Runner for IDApTIK
# Uses the 'nu' interpreter for commands, aligning with user's nushell preference.

# --- Configuration Variables ---
FLATC_OPTS = "--rust -o core/src --gen-object-api --json -o backend/lib/idaptik_core/flatbuffers --js -o client/src/network/flatbuffers"

# --- Core Development Commands ---

# Default rule: shows available commands
@default:
    just --list

# Runs the cross-language validation and schema generation script
@validate:
    ./config/build_scripts/validate.nu

# Installs all Elixir, Rust, and Rescript dependencies
@deps:
    # Elixir dependencies
    cd backend && mix deps.get
    # Rust dependencies (Cargo resolves automatically)
    cd core && cargo check
    # Rescript/Client dependencies (assuming Deno/npm for now, can be updated to Deno native dependencies)
    cd client && npm install

# --- Test Commands ---

@test-unit-all: validate
    # 1. Rust Unit Tests
    cd core && cargo test --all-features
    # 2. Elixir Unit Tests (excluding integration tests)
    cd backend && mix test --exclude integration
    # 3. Rescript Tests (requires Deno to run the rescript build/test)
    cd client && deno run -A --unstable npm:rescript build
    cd client && deno test src/**/*.res

@test-integration:
    # Requires Podman Compose to be running services (ArangoDB, Dragonfly, XTDB)
    podman-compose -f config/podman-compose.yml up -d
    cd backend && mix test --only integration
    podman-compose -f config/podman-compose.yml down

# --- Build Commands ---

# Builds the core Rust binary (high optimization for release/Port)
@build-core-release: validate
    @echo "Building Rust Core with LLVM (Release Mode)..."
    cd core && cargo build --release

# Builds the Elixir backend (used for Podman image)
@build-elixir-release: validate
    @echo "Building Elixir Backend..."
    cd backend && mix do deps.get, release

# Builds the final Tauri client application (cross-platform desktop executable)
@build-client-release: validate
    @echo "Building Tauri Client with Rescript/Svelte..."
    cd client && npm run tauri build

# --- Utility Commands ---

# Generates all FlatBuffers schema files in all languages (used by validate)
# Note: This is exposed here but executed implicitly by the validate script
@generate-schemas:
    @echo "Generating FlatBuffers schemas..."
    flatc $FLATC_OPTS backend/priv/protos/game_state.fbs

# Runs the Elixir backend for local development
@run-backend:
    cd backend && mix phx.server
