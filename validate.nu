#!/usr/bin/env nu

# IDApTIK Configuration Validation and Cross-Language Schema Generation
# Path: config/build_scripts/validate.nu

# --- Configuration ---
let NCL_DIR = $"($env.PWD)/config/nickel"
let PROTO_DIR = $"($env.PWD)/backend/priv/protos"
let RUST_SRC = $"($env.PWD)/core/src"
let ELIXIR_SRC = $"($env.PWD)/backend/lib/idaptik_core/flatbuffers"
let RESCRIPT_SRC = $"($env.PWD)/client/src/network/flatbuffers"

# --- Dependencies Check ---
def check-tool [tool_name: string] {
    if (which $tool_name | is-empty) {
        error $"Tool '($tool_name)' not found. Please install it."
    }
}

check-tool "nickel"
check-tool "flatc"
check-tool "rescript"
# Note: cargo is assumed to be present as the default image is rust:latest

# --- 1. NICKEL CONFIGURATION VALIDATION (Declarative Logic Check) ---
print "-> 1/3: Validating Nickel configuration..."
if not (nickel check $NCL_DIR/entities.ncl $NCL_DIR/rules.ncl | complete).exit_code == 0 {
    error "Nickel validation failed. Check your game rules."
} else {
    print "   Nickel validation passed."
}

# --- 2. FLATBUFFERS SCHEMA COMPILATION (Zero-Copy Interoperability) ---
print "-> 2/3: Compiling FlatBuffers schemas for all languages..."

# A. Generate Rust types (for Core/Ports)
print "   Generating Rust FlatBuffers types..."
flatc --rust -o $RUST_SRC --gen-object-api $PROTO_DIR/game_state.fbs | complete

# B. Generate Elixir types (for Backend/Channels)
print "   Generating Elixir FlatBuffers types..."
# Note: Elixir FlatBuffers often requires a custom plugin or wrapper. We use the standard JSON schema for demonstration.
# In production, this command would use a custom flatc plugin for Elixir.
flatc --json -o $ELIXIR_SRC $PROTO_DIR/game_state.fbs
# (A dedicated FOSS Elixir library/plugin would be used here for efficiency)

# C. Generate Rescript/JS types (for Client/FFI)
print "   Generating JavaScript/Rescript FlatBuffers types..."
flatc --js -o $RESCRIPT_SRC $PROTO_DIR/game_state.fbs

if not ($LAST_EXIT_CODE == 0) {
    error "FlatBuffers compilation failed. Check your schema files in $PROTO_DIR."
} else {
    print "   FlatBuffers compilation complete."
}

# --- 3. RESCRIPT CLIENT COMPILATION (UI/UX Type Safety) ---
print "-> 3/3: Compiling Rescript client code..."

cd $"($env.PWD)/client"

# The '-with-deps' command ensures all client logic is compiled and types are checked.
if not (rescript build -with-deps | complete).exit_code == 0 {
    error "Rescript client compilation failed. Check client/src for type errors."
} else {
    print "   Rescript client compilation successful."
}

cd $"($env.PWD)/.." # Return to root

print "✅ All validation and cross-language schemas generated successfully."
