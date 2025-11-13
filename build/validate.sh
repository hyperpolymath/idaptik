#!/usr/bin/env bash
# IDApTIK Configuration Validation and Cross-Language Schema Generation (Bash Equivalent)

set -euo pipefail # Exit immediately if a command exits with a non-zero status

# --- Configuration ---
NCL_DIR="./config/nickel"
PROTO_DIR="./backend/priv/protos"
RUST_SRC="./core/src"
ELIXIR_SRC="./backend/lib/idaptik_core/flatbuffers"
RESCRIPT_SRC="./client/src/network/flatbuffers"

# --- 1. NICKEL CONFIGURATION VALIDATION (Logic Check) ---
echo "-> 1/3: Validating Nickel configuration..."
if ! nickel check "$NCL_DIR/entities.ncl" "$NCL_DIR/rules.ncl"; then
    echo "ERROR: Nickel validation failed. Check your game rules."
    exit 1
fi
echo "   Nickel validation passed."

# --- 2. FLATBUFFERS SCHEMA COMPILATION (Zero-Copy Interoperability) ---
echo "-> 2/3: Compiling FlatBuffers schemas for all languages..."

# A. Generate Rust types (for Core/Ports)
echo "   Generating Rust FlatBuffers types..."
flatc --rust -o "$RUST_SRC" --gen-object-api "$PROTO_DIR/game_state.fbs"

# B. Generate Elixir types (using JSON schema for simplified interop in this layer)
echo "   Generating Elixir FlatBuffers types..."
flatc --json -o "$ELIXIR_SRC" "$PROTO_DIR/game_state.fbs"

# C. Generate Rescript/JS types (for Client/FFI)
echo "   Generating JavaScript/Rescript FlatBuffers types..."
flatc --js -o "$RESCRIPT_SRC" "$PROTO_DIR/game_state.fbs"

# Check the exit status of the last flatc command
if [ $? -ne 0 ]; then
    echo "ERROR: FlatBuffers compilation failed. Check your schema files."
    exit 1
fi
echo "   FlatBuffers compilation complete."

# --- 3. RESCRIPT CLIENT COMPILATION (UI/UX Type Safety) ---
echo "-> 3/3: Compiling Rescript client code..."

# Assuming Rescript CLI is globally installed or available via PATH
(cd client && rescript build -with-deps)

if [ $? -ne 0 ]; then
    echo "ERROR: Rescript client compilation failed. Check client/src for type errors."
    exit 1
fi

echo "✅ All validation and cross-language schemas generated successfully."
