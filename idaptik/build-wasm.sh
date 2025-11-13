#!/bin/bash
set -e

echo "🦀 Building Rust engine to WASM..."

cd engine

# Install wasm-pack if not present
if ! command -v wasm-pack &> /dev/null; then
    echo "📦 Installing wasm-pack..."
    cargo install wasm-pack
fi

# Build for web target
wasm-pack build --target web --out-dir pkg

echo "✅ Rust WASM build complete!"
echo "📦 Package available at: engine/pkg/"

# Copy to frontend for development
mkdir -p ../frontend/src/wasm
cp pkg/* ../frontend/src/wasm/ 2>/dev/null || true

echo "🎮 Ready for frontend integration!"
