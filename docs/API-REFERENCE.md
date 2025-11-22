# Idaptik API Reference

**Complete API documentation for the Idaptik Reversible VM**

Version: 2.0.0
Last Updated: 2025-11-22

---

## Core Modules

### State Module

**File:** `src/core/State.res`

Manages VM state (variable name → integer value mappings).

#### Types

```rescript
type state = Js.Dict.t<int>
```

A state is a dictionary mapping variable names (strings) to integer values.

#### Functions

##### `createState`

Create a new state with specified variables.

```rescript
let createState = (
  ~variables: array<string>,
  ~initialValue: int=0,
  ()
): state
```

**Parameters:**
- `variables` - Array of variable names to initialize
- `initialValue` - Initial value for all variables (default: 0)

**Returns:** New state dictionary

**Example:**
```rescript
let state = State.createState(~variables=["x", "y", "z"], ~initialValue=0)
// Result: { x: 0, y: 0, z: 0 }
```

##### `cloneState`

Create a deep copy of a state.

```rescript
let cloneState = (state: state): state
```

**Parameters:**
- `state` - State to clone

**Returns:** New state with identical values

**Example:**
```rescript
let original = State.createState(~variables=["x"], ())
Js.Dict.set(original, "x", 42)
let copy = State.cloneState(original)
// copy is independent of original
```

##### `statesMatch`

Check if two states are identical.

```rescript
let statesMatch = (a: state, b: state): bool
```

**Parameters:**
- `a` - First state
- `b` - Second state

**Returns:** `true` if states have same variables with same values

**Example:**
```rescript
let s1 = State.createState(~variables=["x"], ())
let s2 = State.createState(~variables=["x"], ())
Js.Dict.set(s1, "x", 10)
Js.Dict.set(s2, "x", 10)

State.statesMatch(s1, s2)  // true
```

##### `serializeState`

Convert state to JSON string.

```rescript
let serializeState = (state: state): string
```

**Parameters:**
- `state` - State to serialize

**Returns:** JSON string representation

**Example:**
```rescript
let state = State.createState(~variables=["x", "y"], ())
Js.Dict.set(state, "x", 10)
let json = State.serializeState(state)
// Result: "{\"x\":10,\"y\":0}"
```

##### `deserializeState`

Parse JSON string to state.

```rescript
let deserializeState = (json: string): state
```

**Parameters:**
- `json` - JSON string to parse

**Returns:** State object

**Example:**
```rescript
let json = "{\"x\":10,\"y\":5}"
let state = State.deserializeState(json)
// Result: state with x=10, y=5
```

---

### Instruction Module

**File:** `src/core/Instruction.res`

Defines the instruction interface.

#### Types

```rescript
type t = {
  instructionType: string,
  args: array<string>,
  execute: Js.Dict.t<int> => unit,
  invert: Js.Dict.t<int> => unit,
}
```

**Fields:**
- `instructionType` - Instruction name (e.g., "ADD", "SWAP")
- `args` - Variable names affected by instruction
- `execute` - Function to execute instruction forward
- `invert` - Function to reverse instruction

**Reversibility Property:**
```rescript
// For any state s and instruction i:
i.execute(s)
i.invert(s)
// s is now back to original state
```

---

### VM Module

**File:** `src/core/VM.res`

The reversible virtual machine.

#### Types

```rescript
type t = {
  mutable state: Js.Dict.t<int>,
  mutable history: array<Instruction.t>,
}
```

#### Functions

##### `make`

Create a new VM instance.

```rescript
let make = (initialState: Js.Dict.t<int>): t
```

**Parameters:**
- `initialState` - Starting state for VM

**Returns:** New VM instance

**Example:**
```rescript
let state = State.createState(~variables=["x"], ())
let vm = VM.make(state)
```

##### `run`

Execute an instruction.

```rescript
let run = (vm: t, instruction: Instruction.t): unit
```

**Parameters:**
- `vm` - VM instance
- `instruction` - Instruction to execute

**Side Effects:**
- Updates `vm.state`
- Appends instruction to `vm.history`

**Example:**
```rescript
VM.run(vm, Add.make("x", "y"))
```

##### `undo`

Reverse the last instruction.

```rescript
let undo = (vm: t): option<Instruction.t>
```

**Parameters:**
- `vm` - VM instance

**Returns:**
- `Some(instruction)` - The instruction that was undone
- `None` - If history is empty

**Side Effects:**
- Executes `invert` on last instruction
- Removes instruction from history

**Example:**
```rescript
VM.run(vm, Add.make("x", "y"))
VM.undo(vm)  // Reverses the ADD
```

##### `getCurrentState`

Get current state (immutable copy).

```rescript
let getCurrentState = (vm: t): Js.Dict.t<int>
```

**Parameters:**
- `vm` - VM instance

**Returns:** Clone of current state

**Example:**
```rescript
let state = VM.getCurrentState(vm)
```

##### `resetState`

Replace VM state.

```rescript
let resetState = (vm: t, newState: Js.Dict.t<int>): unit
```

**Parameters:**
- `vm` - VM instance
- `newState` - New state to set

**Side Effects:**
- Replaces `vm.state`
- Clears `vm.history`

##### `historyLength`

Get number of executed instructions.

```rescript
let historyLength = (vm: t): int
```

**Parameters:**
- `vm` - VM instance

**Returns:** Length of history array

---

## Instructions

### ADD

**File:** `src/core/instructions/Add.res`

Add two variables: `a = a + b`

#### Function

```rescript
let make = (varA: string, varB: string): Instruction.t
```

**Parameters:**
- `varA` - Variable to modify (a = a + b)
- `varB` - Variable to add

**Operation:**
- Forward: `a = a + b`
- Inverse: `a = a - b`

**Example:**
```rescript
let instr = Add.make("x", "y")
// If x=10, y=5:
instr.execute(state)  // x=15, y=5
instr.invert(state)   // x=10, y=5
```

---

### SUB

**File:** `src/core/instructions/Sub.res`

Subtract two variables: `a = a - b`

#### Function

```rescript
let make = (varA: string, varB: string): Instruction.t
```

**Parameters:**
- `varA` - Variable to modify
- `varB` - Variable to subtract

**Operation:**
- Forward: `a = a - b`
- Inverse: `a = a + b`

---

### SWAP

**File:** `src/core/instructions/Swap.res`

Exchange values of two variables.

#### Function

```rescript
let make = (varA: string, varB: string): Instruction.t
```

**Parameters:**
- `varA` - First variable
- `varB` - Second variable

**Operation:**
- Forward: swap(a, b)
- Inverse: swap(a, b) (self-inverse!)

**Example:**
```rescript
let instr = Swap.make("x", "y")
// If x=10, y=20:
instr.execute(state)  // x=20, y=10
instr.execute(state)  // x=10, y=20 (back to original)
```

---

### NEGATE

**File:** `src/core/instructions/Negate.res`

Negate a variable: `a = -a`

#### Function

```rescript
let make = (varA: string): Instruction.t
```

**Parameters:**
- `varA` - Variable to negate

**Operation:**
- Forward: `a = -a`
- Inverse: `a = -a` (self-inverse!)

---

### XOR

**File:** `src/core/instructions/Xor.res`

Bitwise XOR: `a = a ⊕ b`

#### Function

```rescript
let make = (varA: string, varB: string): Instruction.t
```

**Parameters:**
- `varA` - Variable to modify
- `varB` - Variable to XOR with

**Operation:**
- Forward: `a = a XOR b`
- Inverse: `a = a XOR b` (self-inverse!)

**Example:**
```rescript
let instr = Xor.make("x", "y")
// If x=12 (0b1100), y=10 (0b1010):
instr.execute(state)  // x=6 (0b0110)
instr.execute(state)  // x=12 (back to original)
```

---

### FLIP

**File:** `src/core/instructions/Flip.res`

Bitwise NOT: `a = ~a`

#### Function

```rescript
let make = (varA: string): Instruction.t
```

**Parameters:**
- `varA` - Variable to flip

**Operation:**
- Forward: `a = ~a`
- Inverse: `a = ~a` (self-inverse!)

---

### ROL

**File:** `src/core/instructions/Rol.res`

Rotate bits left.

#### Function

```rescript
let make = (varA: string, ~bits: int=1, ()): Instruction.t
```

**Parameters:**
- `varA` - Variable to rotate
- `bits` - Number of positions to rotate (default: 1)

**Operation:**
- Forward: Rotate left by `bits` positions
- Inverse: Rotate right by `bits` positions

---

### ROR

**File:** `src/core/instructions/Ror.res`

Rotate bits right.

#### Function

```rescript
let make = (varA: string, ~bits: int=1, ()): Instruction.t
```

**Parameters:**
- `varA` - Variable to rotate
- `bits` - Number of positions to rotate (default: 1)

**Operation:**
- Forward: Rotate right by `bits` positions
- Inverse: Rotate left by `bits` positions

---

### NOOP

**File:** `src/core/instructions/Noop.res`

No operation (does nothing).

#### Function

```rescript
let make = (): Instruction.t
```

**Operation:**
- Forward: (nothing)
- Inverse: (nothing)

**Use Case:** Placeholder, timing, testing

---

## Puzzle Module

**File:** `src/core/Puzzle.res`

Load and manage puzzles.

#### Types

```rescript
type puzzle = {
  name: string,
  description: string,
  initialState: Js.Dict.t<int>,
  goalState: option<Js.Dict.t<int>>,
  maxMoves: option<int>,
  steps: option<array<puzzleStep>>,
  allowedInstructions: option<array<string>>,
  difficulty: option<string>,
}
```

#### Functions

##### `loadPuzzleFromFile`

Load puzzle from JSON file.

```rescript
let loadPuzzleFromFile = (filePath: string): option<puzzle>
```

**Parameters:**
- `filePath` - Path to puzzle JSON file

**Returns:**
- `Some(puzzle)` if successful
- `None` if file not found or parse error

**Example:**
```rescript
let puzzle = Puzzle.loadPuzzleFromFile("data/puzzles/beginner_01.json")
```

##### `checkGoal`

Check if current state matches goal.

```rescript
let checkGoal = (current: Js.Dict.t<int>, goal: Js.Dict.t<int>): bool
```

**Parameters:**
- `current` - Current state
- `goal` - Goal state

**Returns:** `true` if states match

##### `printPuzzleInfo`

Print puzzle information to console.

```rescript
let printPuzzleInfo = (p: puzzle): unit
```

---

## Usage Patterns

### Basic VM Usage

```rescript
// 1. Create state
let state = State.createState(~variables=["x", "y"], ())
Js.Dict.set(state, "x", 10)
Js.Dict.set(state, "y", 5)

// 2. Create VM
let vm = VM.make(state)

// 3. Execute instructions
VM.run(vm, Add.make("x", "y"))
VM.run(vm, Swap.make("x", "y"))

// 4. Undo operations
VM.undo(vm)
VM.undo(vm)

// 5. Check state
let finalState = VM.getCurrentState(vm)
```

### Property-Based Testing

```rescript
// Test reversibility property
let testReversibility = (instr: Instruction.t): bool => {
  let state = State.createState(~variables=["x", "y"], ())
  let original = State.cloneState(state)

  instr.execute(state)
  instr.invert(state)

  State.statesMatch(state, original)  // Should be true!
}
```

### Puzzle Solving

```rescript
// Load puzzle
let puzzle = Puzzle.loadPuzzleFromFile("puzzle.json")->Belt.Option.getExn

// Set up VM
let vm = VM.make(puzzle.initialState)

// Solve...
VM.run(vm, Add.make("x", "y"))
VM.run(vm, Swap.make("x", "z"))

// Check if solved
let solved = switch puzzle.goalState {
| Some(goal) => State.statesMatch(VM.getCurrentState(vm), goal)
| None => false
}
```

---

## Error Handling

### Missing Variables

If you try to operate on non-existent variables:

```rescript
let state = State.createState(~variables=["x"], ())
let instr = Add.make("x", "nonexistent")
instr.execute(state)
// nonexistent defaults to 0
```

### Type Safety

ReScript's type system prevents:
- Null pointer exceptions
- Type coercion bugs
- Invalid state access

If it compiles, types are correct!

---

## Performance Considerations

### State Cloning

`VM.getCurrentState()` creates a deep clone. For frequent reads, cache the result:

```rescript
let state = VM.getCurrentState(vm)
// Use state multiple times
```

### History Growth

VM history grows unbounded. For long-running sessions, consider periodic resets:

```rescript
if VM.historyLength(vm) > 10000 {
  VM.resetState(vm, VM.getCurrentState(vm))
}
```

---

## See Also

- **[BEGINNER-TUTORIAL.md](tutorials/BEGINNER-TUTORIAL.md)** - Getting started
- **[PUZZLE-CREATION-GUIDE.md](tutorials/PUZZLE-CREATION-GUIDE.md)** - Create puzzles
- **[Examples](../examples/)** - Sample programs
- **[RSR-COMPLIANCE.md](../RSR-COMPLIANCE.md)** - Project standards

---

**Questions?** Open an issue on GitHub or check the [CONTRIBUTING.md](../CONTRIBUTING.md) guide.
