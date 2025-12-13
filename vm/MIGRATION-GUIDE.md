# Migration Guide: Bun + TypeScript → Deno + ReScript

## Overview

This project has been fully migrated from:
- **Before:** Bun + TypeScript + npm
- **After:** Deno + ReScript (no npm/bun/typescript)

## What Changed

### Technology Stack

| Component | Before | After |
|-----------|--------|-------|
| Runtime | Bun | Deno |
| Language | TypeScript | ReScript |
| Package Manager | Bun/npm | None (Deno native) |
| Build Tool | tsc | ReScript compiler |
| Task Runner | npm scripts | Just (justfile) |

### File Structure

#### Removed Files
- ❌ `package.json` - No longer needed (backed up as `package.json.old`)
- ❌ `bun.lock` - Bun lock file removed
- ❌ `tsconfig.json` - TypeScript config removed (backed up as `tsconfig.json.old`)
- ❌ `tsconfig.dev.json` - Dev config removed
- ❌ `node_modules/` - Node modules directory removed
- ❌ `core/*.ts` - TypeScript sources (kept as reference in `_old_typescript/`)
- ❌ `src/cli.ts` - Old CLI (backed up)

#### New Files
- ✅ `rescript.json` - ReScript configuration
- ✅ `deno.json` - Deno configuration with tasks
- ✅ `justfile` - Comprehensive build system
- ✅ `src/core/*.res` - ReScript core modules
- ✅ `src/core/instructions/*.res` - ReScript instructions
- ✅ `src/CLI.res` - New ReScript CLI

### Directory Structure

```
idaptik-reversible/
├── src/
│   ├── core/
│   │   ├── Instruction.res      # Core instruction interface
│   │   ├── State.res            # State management
│   │   ├── VM.res               # Reversible VM
│   │   └── instructions/
│   │       ├── Add.res          # ADD instruction
│   │       ├── Sub.res          # SUB instruction
│   │       ├── Swap.res         # SWAP instruction
│   │       ├── Negate.res       # NEGATE instruction
│   │       └── Noop.res         # NOOP instruction
│   └── CLI.res                  # Command-line interface
├── data/
│   └── puzzles/
│       ├── vault_7.json         # Puzzle files (unchanged)
│       └── vault_defuse.json
├── rescript.json                # ReScript configuration
├── deno.json                    # Deno configuration
├── justfile                     # Build system
├── .gitignore                   # Updated for Deno + ReScript
└── MIGRATION-GUIDE.md          # This file

Legacy files (for reference):
├── _old_typescript/             # Backed up TypeScript sources
│   ├── package.json.old
│   ├── tsconfig.json.old
│   └── core/                    # Original TS files
```

## Installation & Setup

### Prerequisites

Install required tools:

```bash
# 1. Install Deno
curl -fsSL https://deno.land/install.sh | sh

# 2. Install ReScript compiler (globally)
npm install -g rescript@latest
# OR use npx (no global install)

# 3. Install Just task runner
cargo install just
# OR on Fedora: sudo dnf install just

# 4. Optional: Install watchexec for watch mode
cargo install watchexec-cli
# OR on Fedora: sudo dnf install watchexec
```

### Verify Installation

```bash
just check-deps
# OR
just doctor
```

## Usage

### Building

```bash
# Build ReScript to JavaScript
just build

# Watch mode (auto-rebuild on changes)
just watch

# Clean build artifacts
just clean
```

### Running

```bash
# Run CLI
just run

# Run demonstration
just demo

# Run tests
just test
```

### Development

```bash
# Start development mode
just dev

# In another terminal:
just watch

# Lint code
just lint

# Format code
just format
```

### Puzzles

```bash
# List available puzzles
just list-puzzles

# Run a specific puzzle
just puzzle vault_7

# Create new puzzle
just create-puzzle my_puzzle
```

### Full Workflow

```bash
# Clean build + test + lint
just ci

# Full verification
just verify

# Check project status
just status

# Show code statistics
just stats
```

## Key Differences

### 1. Type System

**TypeScript:**
```typescript
interface Instruction {
  type: string;
  args: string[];
  execute(state: Record<string, number>): void;
  invert(state: Record<string, number>): void;
}
```

**ReScript:**
```rescript
type t = {
  instructionType: string,
  args: array<string>,
  execute: Js.Dict.t<int> => unit,
  invert: Js.Dict.t<int> => unit,
}
```

### 2. Module System

**TypeScript:**
```typescript
import { Instruction } from "./instruction";
export class Add implements Instruction { ... }
```

**ReScript:**
```rescript
// Automatic module system - no imports needed!
let make = (a: string, b: string): Instruction.t => { ... }
```

### 3. Running Code

**Before (Bun + TypeScript):**
```bash
npm run build
npm run dev
bun run src/devRunner.ts
```

**After (Deno + ReScript):**
```bash
just build
just demo
just run
```

## Benefits of the Migration

### 1. **Simpler Dependency Management**
- ❌ No `node_modules/` (saves ~100MB)
- ❌ No `package.json` conflicts
- ✅ Deno native imports
- ✅ No dependency hell

### 2. **Type Safety**
- ReScript has stronger type inference than TypeScript
- Compile-time guarantees (no runtime type errors)
- Pattern matching for exhaustive checks

### 3. **Performance**
- ReScript generates highly optimized JavaScript
- Deno runtime is fast and secure
- Smaller bundle sizes

### 4. **Developer Experience**
- Justfile provides comprehensive build system
- Clear error messages
- Fast compilation
- Built-in formatter

### 5. **Security**
- Deno's permission system (explicit --allow-read, etc.)
- No implicit file system access
- Secure by default

## Common Tasks

### Add a New Instruction

1. Create `src/core/instructions/MyInstruction.res`:

```rescript
let make = (args...): Instruction.t => {
  instructionType: "MY_INSTR",
  args: [...],
  execute: state => {
    // Forward operation
  },
  invert: state => {
    // Reverse operation (undo)
  },
}
```

2. Build and test:

```bash
just build
just test
```

### Debugging

```bash
# Check ReScript syntax
just check

# Run with verbose Deno output
deno run --allow-read --log-level=debug src/CLI.res.js demo

# Check compiled JavaScript
cat src/CLI.res.js
```

### Performance Profiling

```bash
# Benchmark (TODO: implement)
just benchmark

# Profile (TODO: implement)
just profile
```

## Troubleshooting

### ReScript Compiler Not Found

```bash
# Option 1: Install globally
npm install -g rescript

# Option 2: Use npx (automatic)
npx rescript build

# Option 3: Use bun (if available)
bunx rescript build
```

### Deno Permission Errors

```bash
# Add required permissions:
deno run --allow-read --allow-write src/CLI.res.js
```

### Build Errors

```bash
# Clean and rebuild
just clean
just build

# Deep clean (including cache)
just clean-all
just build
```

### Watch Mode Not Working

```bash
# Install watchexec
cargo install watchexec-cli

# OR use ReScript's built-in watch
just watch
```

## Rollback (If Needed)

If you need to rollback to TypeScript:

1. Restore backed up files:
```bash
mv _old_typescript/package.json.old package.json
mv _old_typescript/tsconfig.json.old tsconfig.json
mv _old_typescript/core/* core/
```

2. Reinstall dependencies:
```bash
bun install
```

3. Build TypeScript:
```bash
npm run build
```

## Resources

- [ReScript Documentation](https://rescript-lang.org/docs/)
- [Deno Manual](https://deno.land/manual)
- [Just Manual](https://github.com/casey/just)
- [Reversible Computing](https://en.wikipedia.org/wiki/Reversible_computing)

## Support

- **Issues:** Report at project repository
- **Questions:** See `just help`
- **License:** AGPL-3.0
- **Authors:** Joshua & Jonathan Jewell

---

**Migration Date:** 2025-11-21
**Migration Status:** ✅ Complete
