# MAKEFILE - Alternative Task Runner for IDApTIK
# Note: Relies on standard shell commands and assumes tools (mix, cargo, flatc) are in PATH.

.PHONY: all validate deps test build clean

# --- Configuration Variables ---
FLATC_OPTS = --rust -o core/src --gen-object-api --json -o backend/lib/idaptik_core/flatbuffers --js -o client/src/network/flatbuffers

# Default target: shows help
all: help

help:
	@echo "Available commands:"
	@echo "  validate        - Run cross-language schema validation (Rescript, Nickel, FlatBuffers)."
	@echo "  deps            - Install all Elixir, Rust, and Rescript dependencies."
	@echo "  test            - Run all unit and integration tests."
	@echo "  build           - Build all release artifacts (Core, Client, Elixir)."
	@echo "  clean           - Clean up all build artifacts."

# --- Core Development Commands ---

validate:
	@echo "Running cross-language validation and schema generation..."
	./config/build_scripts/validate.nu

deps:
	@echo "Installing dependencies..."
	cd backend && mix deps.get
	cd client && npm install
	# cargo dependencies resolve implicitly on first build/check

# --- Test Commands ---

test: test-unit test-integration

test-unit: validate
	@echo "Running unit tests (Rust, Elixir, Rescript)..."
	cd core && cargo test --all-features
	cd backend && mix test --exclude integration
	cd client && deno run -A --unstable npm:rescript build
	cd client && deno test src/**/*.res

test-integration:
	@echo "Starting Podman services for integration tests (ArangoDB, Dragonfly, XTDB)..."
	podman-compose -f config/podman-compose.yml up -d
	cd backend && mix test --only integration
	podman-compose -f config/podman-compose.yml down

# --- Build Commands ---

build: validate build-core build-client build-elixir

build-core:
	@echo "Building Rust Core with LLVM (Release Mode)..."
	cd core && cargo build --release

build-elixir:
	@echo "Building Elixir Backend Release..."
	cd backend && mix do deps.get, release

build-client:
	@echo "Building Tauri Client Executable..."
	cd client && npm run tauri build

# --- Utility Commands ---

clean:
	@echo "Cleaning build artifacts..."
	cd core && cargo clean
	cd backend && mix clean
	cd client && rm -rf dist target node_modules
