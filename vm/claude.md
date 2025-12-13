# Claude Integration Guide for Idaptik

This document provides guidance for AI assistants (particularly Claude) working with the Idaptik reversible computation VM codebase.

## Project Overview

**Idaptik** is a reversible computation virtual machine where every operation can be perfectly undone. Built with ReScript (compiled to JavaScript) and run on Deno.

### Core Concept
Every instruction has an inverse that reverses its effect without information loss:
```
Forward:  x=5  →  [ADD x 3]  →  x=8
Reverse:  x=8  ←  [UNDO]     ←  x=5
```

## Technology Stack

- **Language:** ReScript (.res files) → compiles to JavaScript (.res.js)
- **Runtime:** Deno (not Node.js - no npm dependencies!)
- **Build Tool:** Just (command runner - see justfile)
- **Type System:** ReScript's sound type system (no runtime type errors)

## Directory Structure

```
idaptiky/
├── src/
│   ├── core/              # Core VM modules
│   │   ├── Instruction.res
│   │   ├── State.res
│   │   ├── VM.res
│   │   └── instructions/  # Individual instruction implementations
│   └── CLI.res            # Command-line interface
├── data/puzzles/          # JSON puzzle definitions
├── tests/                 # Test files
├── rescript.json          # ReScript compiler config
├── justfile              # Build system (600+ lines!)
└── package.json          # Minimal (just for ReScript compiler)
```

## Development Workflow

### Essential Commands

```bash
# Build system (use Just, not npm!)
just build              # Compile ReScript → JavaScript
just watch              # Auto-rebuild on changes
just clean              # Remove build artifacts

# Running
just demo               # Run demonstration
just test               # Run test suite
just run                # Run CLI

# Quality checks
just format             # Format ReScript code
just lint               # Lint code
just verify             # Build + test + lint
just ci                 # Full CI pipeline

# Information
just help               # Show all available commands
just status             # Project status
just stats              # Code statistics
```

### Build Process

1. ReScript compiler reads `.res` files
2. Compiles to `.res.js` JavaScript files
3. Deno executes the JavaScript (no bundling needed!)

**Important:** Never edit `.res.js` files directly - they're generated!

## ReScript Language Guide

### Key Differences from JavaScript/TypeScript

1. **Immutability by default**
   ```rescript
   let x = 5  // Immutable binding
   ```

2. **Explicit mutation**
   ```rescript
   Js.Dict.set(state, "x", 10)  // Mutating a dictionary
   ```

3. **Pattern matching**
   ```rescript
   switch instruction {
   | Add(a, b) => handleAdd(a, b)
   | Sub(a, b) => handleSub(a, b)
   | _ => handleDefault()
   }
   ```

4. **No null/undefined** - Uses `option<'a>` instead
   ```rescript
   Some(value)  // Has value
   None         // No value
   ```

5. **Sound type system** - If it compiles, types are guaranteed correct

### Common Patterns in This Codebase

**State Management:**
```rescript
type state = Js.Dict.t<int>  // Dictionary of variable names to integers

let state = State.createState(~variables=["x", "y"], ~initialValue=0)
```

**Instruction Interface:**
```rescript
type t = {
  execute: state => state,
  invert: state => state,
  toString: unit => string,
}
```

**Creating Instructions:**
```rescript
let make = (varA: string, varB: string): t => {
  execute: state => { /* implementation */ },
  invert: state => { /* inverse implementation */ },
  toString: () => `ADD ${varA} ${varB}`,
}
```

## File Organization

### Core Modules

- **`State.res`**: State creation and management
  - `createState()`: Initialize VM state
  - Helper functions for state manipulation

- **`Instruction.res`**: Instruction interface definition
  - Defines the instruction type `t`
  - Common interface for all instructions

- **`VM.res`**: Virtual machine implementation
  - `make()`: Create VM instance
  - `run()`: Execute instruction
  - `undo()`: Reverse last instruction
  - Maintains execution history

### Instruction Implementations

Each instruction in `src/core/instructions/`:
- **Add.res**: `a = a + b`, inverse: `a = a - b`
- **Sub.res**: `a = a - b`, inverse: `a = a + b`
- **Swap.res**: Swap two variables (self-inverse)
- **Negate.res**: `a = -a` (self-inverse)
- **Noop.res**: No operation (self-inverse)

**Pattern:** Each instruction exports a `make()` function that returns an instruction record implementing the interface.

## Testing

### Test Structure

```rescript
// Test pattern
let testAddition = () => {
  let state = State.createState(~variables=["x", "y"], ~initialValue=0)
  Js.Dict.set(state, "x", 10)
  Js.Dict.set(state, "y", 5)

  let vm = VM.make(state)
  VM.run(vm, Add.make("x", "y"))

  // Assert
  VM.getCurrentState(vm)->Js.Dict.get("x") == Some(15)
}
```

### Running Tests

```bash
just test                # Run all tests
deno run --allow-read src/CLI.res.js test  # Direct invocation
```

## Common Tasks for AI Assistants

### Adding a New Instruction

1. Create `src/core/instructions/NewInstruction.res`
2. Implement the interface:
   ```rescript
   let make = (args) => {
     execute: state => { /* forward logic */ },
     invert: state => { /* reverse logic */ },
     toString: () => "INSTRUCTION_NAME ...",
   }
   ```
3. Add test in test suite
4. Build: `just build`
5. Test: `just test`

### Debugging

1. **Check ReScript compilation:**
   ```bash
   just build
   # Look for type errors or compilation failures
   ```

2. **Add debug output:**
   ```rescript
   Js.Console.log("Debug: " ++ Js.Json.stringify(state))
   ```

3. **Run specific test:**
   ```bash
   just test
   # All tests run - add debug output to specific test
   ```

### Modifying the VM

- **Adding history tracking:** Modify `VM.res`
- **State validation:** Add to `State.res`
- **New instruction types:** Update `Instruction.res` interface if needed

## Important Conventions

### Code Style

- **Module names:** PascalCase (State.res, VM.res)
- **Function names:** camelCase (createState, make)
- **Type names:** lowercase (state, instruction, t)
- **Constants:** UPPER_CASE for instruction names in strings

### Reversibility Requirements

**Critical:** Every instruction must be perfectly reversible!

Test checklist for new instructions:
1. ✓ Forward execution works correctly
2. ✓ Inverse execution works correctly
3. ✓ `execute(invert(state))` === `state` (perfect reversal)
4. ✓ No information loss during operations

### File Naming

- ReScript source: `*.res`
- Generated JavaScript: `*.res.js` (don't edit!)
- Tests: `*_test.res` or in `tests/` directory
- Puzzles: JSON files in `data/puzzles/`

## Deno Specifics

### Permissions

Deno requires explicit permissions:
```bash
deno run --allow-read src/CLI.res.js    # File read access
deno run --allow-write src/CLI.res.js   # File write access (if needed)
```

### No npm Dependencies

- **No `node_modules`** for runtime (only ReScript compiler uses npm)
- **No package.json dependencies** for runtime
- Everything runs directly in Deno

### Import Style

JavaScript imports in generated code:
```javascript
import * as State from "./core/State.res.js"
```

## Build System (Just)

### Understanding the Justfile

The justfile contains 40+ recipes. Key categories:

1. **Core:** build, clean, run, watch
2. **Development:** dev, demo, test
3. **Quality:** format, lint, verify, ci
4. **Puzzles:** list-puzzles, puzzle, create-puzzle
5. **Info:** status, stats, help, doctor

### Adding New Recipes

```make
# In justfile
my-command:
    #!/usr/bin/env bash
    echo "Running my command"
    deno run --allow-read src/CLI.res.js my-action
```

## Troubleshooting

### Common Issues

1. **"Cannot find module"**
   - Run `just build` to compile ReScript files
   - Check that `.res.js` files exist

2. **Type errors in ReScript**
   - ReScript has very strict types
   - Use `Js.Console.log()` to inspect values
   - Check type signatures match

3. **Deno permission errors**
   - Add appropriate `--allow-*` flags
   - See `deno run --help` for permission options

4. **Build fails**
   - Run `just clean` then `just build`
   - Check `rescript.json` configuration

## Integration Points

### CLI Interface

Entry point: `src/CLI.res`

Commands:
- `help`: Show usage
- `demo`: Run demonstration
- `test`: Run test suite
- `run <puzzle>`: Run puzzle (TODO: implement)

### Puzzle System

Puzzles are JSON files in `data/puzzles/`:

```json
{
  "name": "Puzzle Name",
  "description": "Description",
  "initialState": { "x": 0, "y": 10 },
  "goalState": { "x": 100, "y": 10 },
  "maxMoves": 20,
  "instructions": [
    {"type": "ADD", "args": ["x", "y"]},
    {"type": "SUB", "args": ["x", "z"]}
  ]
}
```

**Note:** Puzzle loading is not yet fully implemented.

## Best Practices for AI Assistance

### When Helping with Code

1. **Always read existing code first** - Don't guess patterns
2. **Respect ReScript idioms** - Don't write JavaScript in ReScript
3. **Test reversibility** - New instructions must be perfectly reversible
4. **Use Just commands** - Don't try to run npm commands
5. **Check types carefully** - ReScript won't compile with type errors

### When Debugging

1. Start with `just build` to see compilation errors
2. Use `just test` to verify functionality
3. Add strategic `Js.Console.log()` calls
4. Check generated `.res.js` files if needed (rare)

### When Refactoring

1. Make small, incremental changes
2. Run `just verify` after each change
3. Don't break reversibility guarantees
4. Update tests to match changes

## Resources

### Documentation

- **MIGRATION-GUIDE.md**: TypeScript → ReScript migration details
- **README.md**: User-facing documentation
- **CONTRIBUTING.md**: Contribution guidelines
- **justfile**: Complete build system reference

### External Resources

- [ReScript Documentation](https://rescript-lang.org/docs)
- [Deno Manual](https://deno.land/manual)
- [Just Manual](https://github.com/casey/just)

## Quick Reference

### Most Common Commands

```bash
just build              # Build after editing .res files
just demo               # See the VM in action
just test               # Verify everything works
just watch              # Auto-rebuild during development
```

### File Extensions

- `.res` - ReScript source (edit these)
- `.res.js` - Generated JavaScript (don't edit)
- `.json` - Puzzle definitions
- `.md` - Documentation

### Key Types

```rescript
type state = Js.Dict.t<int>  // VM state

type instruction = {         // Instruction interface
  execute: state => state,
  invert: state => state,
  toString: unit => string,
}
```

## Version Information

- **Current Version:** v2.0.0 (ReScript/Deno implementation)
- **Previous Version:** v1.0.0 (TypeScript/Node.js - deprecated)
- **License:** Dual-licensed MIT OR Palimpsest v0.8

## Notes for Claude

- This is a **demonstration/educational project** - focus on clarity over performance
- **Type safety is paramount** - if ReScript won't compile it, don't ship it
- **Reversibility is core** - never compromise perfect reversibility
- **Zero dependencies** - keep the runtime dependency-free (only build tools use npm)
- The project showcases **modern web tech done simply** - maintain that philosophy

---

**Last Updated:** 2025-11-22
**Maintained By:** Hyperpolymath
**For:** Claude Code integration
