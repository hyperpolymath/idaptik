# Instruction Reference

**Complete guide to all 13 reversible instructions in Idaptik**

## Table of Contents

1. [Instruction Overview](#instruction-overview)
2. [Arithmetic Instructions](#arithmetic-instructions)
3. [Bitwise Instructions](#bitwise-instructions)
4. [Data Movement](#data-movement)
5. [Special Instructions](#special-instructions)
6. [Instruction Properties](#instruction-properties)

---

## Instruction Overview

| Instruction | Type | Arguments | Reversibility | Use Case |
|-------------|------|-----------|---------------|----------|
| ADD | Arithmetic | a, b | SUB(a, b) | Addition |
| SUB | Arithmetic | a, b | ADD(a, b) | Subtraction |
| MUL | Arithmetic | a, b, c | Clear c | Multiplication |
| DIV | Arithmetic | a, b, q, r | Reconstruct | Division |
| SWAP | Data Movement | a, b | Self-inverse | Exchange values |
| NEGATE | Arithmetic | a | Self-inverse | Sign flip |
| XOR | Bitwise | a, b | Self-inverse | Exclusive OR |
| AND | Bitwise | a, b, c | Clear c | Bitwise AND |
| OR | Bitwise | a, b, c | Clear c | Bitwise OR |
| FLIP | Bitwise | a | Self-inverse | Bitwise NOT |
| ROL | Bitwise | a, bits | ROR(a, bits) | Rotate left |
| ROR | Bitwise | a, bits | ROL(a, bits) | Rotate right |
| NOOP | Special | - | Self-inverse | No operation |

---

## Arithmetic Instructions

### ADD

**Operation**: `a = a + b`

**Inverse**: `a = a - b` (SUB)

**Signature**:
```rescript
Add.make(varA: string, varB: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x", "y"], ~initialValue=0)
Js.Dict.set(state, "x", 10)
Js.Dict.set(state, "y", 5)

let instr = Add.make("x", "y")
instr.execute(state)  // x = 15, y = 5
instr.invert(state)   // x = 10, y = 5 (restored!)
```

**Use Cases**:
- Increment counters
- Accumulate values
- Implement arithmetic sequences

---

### SUB

**Operation**: `a = a - b`

**Inverse**: `a = a + b` (ADD)

**Signature**:
```rescript
Sub.make(varA: string, varB: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x", "y"], ~initialValue=0)
Js.Dict.set(state, "x", 10)
Js.Dict.set(state, "y", 3)

let instr = Sub.make("x", "y")
instr.execute(state)  // x = 7, y = 3
instr.invert(state)   // x = 10, y = 3 (restored!)
```

**Use Cases**:
- Decrement counters
- Calculate differences
- Undo additions

---

### MUL

**Operation**: `c = c + (a * b)` (requires c = 0 initially)

**Inverse**: `c = c - (a * b)`

**Signature**:
```rescript
Mul.make(varA: string, varB: string, varC: string): Instruction.t
Mul.makeInPlace(varA: string, varB: string): Instruction.t  // NOT fully reversible!
```

**Example**:
```rescript
let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
Js.Dict.set(state, "a", 6)
Js.Dict.set(state, "b", 7)
Js.Dict.set(state, "c", 0)  // Ancilla must be 0!

let instr = Mul.make("a", "b", "c")
instr.execute(state)  // a = 6, b = 7, c = 42
instr.invert(state)   // a = 6, b = 7, c = 0 (restored!)
```

**Use Cases**:
- Compute products
- Scaling values
- Bennett's trick demonstration

**Important**: Variable `c` must be 0 before execute for proper reversibility!

---

### DIV

**Operation**: `q = a / b`, `r = a mod b`

**Inverse**: Reconstruct `a = (q * b) + r`

**Signature**:
```rescript
Div.make(varA: string, varB: string, varQ: string, varR: string): Instruction.t
Div.makeSimple(varA: string, varB: string, varQ: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["a", "b", "q", "r"], ~initialValue=0)
Js.Dict.set(state, "a", 17)
Js.Dict.set(state, "b", 5)

let instr = Div.make("a", "b", "q", "r")
instr.execute(state)  // q = 3, r = 2 (17 = 3*5 + 2)
instr.invert(state)   // Clears q and r
```

**Use Cases**:
- Integer division
- Modulo operations
- Decomposition algorithms

**Important**: Storing remainder `r` is crucial for reversibility!

---

## Bitwise Instructions

### XOR

**Operation**: `a = a XOR b`

**Inverse**: `a = a XOR b` (self-inverse!)

**Signature**:
```rescript
Xor.make(varA: string, varB: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["a", "b"], ~initialValue=0)
Js.Dict.set(state, "a", 0b1010)  // 10
Js.Dict.set(state, "b", 0b1100)  // 12

let instr = Xor.make("a", "b")
instr.execute(state)  // a = 0b0110 (6)
instr.execute(state)  // a = 0b1010 (10) - restored!
```

**Use Cases**:
- XOR cipher (one-time pad)
- Toggle bits
- Swapping without temporary variable
- Conditional operations

**Property**: `(a XOR b) XOR b = a` (self-inverse)

---

### AND

**Operation**: `c = a AND b` (requires c = 0 initially)

**Inverse**: `c = 0` (clear ancilla)

**Signature**:
```rescript
And.make(varA: string, varB: string, varC: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
Js.Dict.set(state, "a", 0b1100)  // 12
Js.Dict.set(state, "b", 0b1010)  // 10
Js.Dict.set(state, "c", 0)       // Ancilla!

let instr = And.make("a", "b", "c")
instr.execute(state)  // c = 0b1000 (8)
instr.invert(state)   // c = 0 (cleared)
```

**Use Cases**:
- Bit masking
- Logic gates
- Conditional computation
- Toffoli gate implementation

**Important**: Uses ancilla pattern (Bennett's trick)

---

### OR

**Operation**: `c = a OR b` (requires c = 0 initially)

**Inverse**: `c = 0` (clear ancilla)

**Signature**:
```rescript
Or.make(varA: string, varB: string, varC: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
Js.Dict.set(state, "a", 0b1100)  // 12
Js.Dict.set(state, "b", 0b0011)  // 3
Js.Dict.set(state, "c", 0)       // Ancilla!

let instr = Or.make("a", "b", "c")
instr.execute(state)  // c = 0b1111 (15)
instr.invert(state)   // c = 0 (cleared)
```

**Use Cases**:
- Combining bit sets
- Logic gates
- Setting multiple bits

---

### FLIP

**Operation**: `a = NOT a` (bitwise NOT)

**Inverse**: `a = NOT a` (self-inverse!)

**Signature**:
```rescript
Flip.make(varA: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x"], ~initialValue=0)
Js.Dict.set(state, "x", 42)

let instr = Flip.make("x")
instr.execute(state)  // x = -43 (bitwise NOT)
instr.execute(state)  // x = 42 (restored!)
```

**Use Cases**:
- Bitwise negation
- Inverting flags
- Complement operations

**Property**: `NOT(NOT(a)) = a` (self-inverse)

---

### ROL

**Operation**: Rotate left by N bits

**Inverse**: ROR (rotate right) by N bits

**Signature**:
```rescript
Rol.make(varA: string, ~bits: int=1, ()): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x"], ~initialValue=0)
Js.Dict.set(state, "x", 0b11110000)  // 240

let instr = Rol.make("x", ~bits=2, ())
instr.execute(state)  // x = 0b11000011 (rotated left 2)
instr.invert(state)   // x = 0b11110000 (restored by ROR 2)
```

**Use Cases**:
- Circular shifts
- Bit permutations
- Cryptographic operations

---

### ROR

**Operation**: Rotate right by N bits

**Inverse**: ROL (rotate left) by N bits

**Signature**:
```rescript
Ror.make(varA: string, ~bits: int=1, ()): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x"], ~initialValue=0)
Js.Dict.set(state, "x", 0b11110000)  // 240

let instr = Ror.make("x", ~bits=2, ())
instr.execute(state)  // x = 0b00111100 (rotated right 2)
instr.invert(state)   // x = 0b11110000 (restored by ROL 2)
```

**Use Cases**:
- Circular shifts
- Undoing ROL
- Bit manipulation

---

## Data Movement

### SWAP

**Operation**: Exchange values of a and b

**Inverse**: SWAP again (self-inverse!)

**Signature**:
```rescript
Swap.make(varA: string, varB: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x", "y"], ~initialValue=0)
Js.Dict.set(state, "x", 10)
Js.Dict.set(state, "y", 20)

let instr = Swap.make("x", "y")
instr.execute(state)  // x = 20, y = 10
instr.execute(state)  // x = 10, y = 20 (restored!)
```

**Use Cases**:
- Variable exchange
- Sorting algorithms
- Register swapping
- Fredkin gate implementation

**Property**: `SWAP(SWAP(a,b)) = (a,b)` (self-inverse)

---

### NEGATE

**Operation**: `a = -a` (arithmetic negation)

**Inverse**: `a = -a` (self-inverse!)

**Signature**:
```rescript
Negate.make(varA: string): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x"], ~initialValue=0)
Js.Dict.set(state, "x", 42)

let instr = Negate.make("x")
instr.execute(state)  // x = -42
instr.execute(state)  // x = 42 (restored!)
```

**Use Cases**:
- Sign inversion
- Negating values
- Two's complement operations

**Property**: `-(-a) = a` (self-inverse)

---

## Special Instructions

### NOOP

**Operation**: Do nothing

**Inverse**: Do nothing (self-inverse!)

**Signature**:
```rescript
Noop.make(): Instruction.t
```

**Example**:
```rescript
let state = State.createState(~variables=["x"], ~initialValue=0)
Js.Dict.set(state, "x", 42)

let instr = Noop.make()
instr.execute(state)  // x = 42 (unchanged)
instr.invert(state)   // x = 42 (still unchanged!)
```

**Use Cases**:
- Placeholder instruction
- Alignment padding
- Testing frameworks
- Instruction count tracking

---

## Instruction Properties

### Self-Inverse Instructions

These instructions are their own inverse:

1. **SWAP** - Swapping twice restores original
2. **NEGATE** - Negating twice restores original
3. **XOR** - XORing twice restores original
4. **FLIP** - Flipping twice restores original
5. **NOOP** - Does nothing in both directions

**Property**: `f(f(x)) = x`

### Instruction Pairs

These instructions have distinct inverses:

1. **ADD / SUB** - Addition and subtraction
2. **ROL / ROR** - Left and right rotation

**Property**: `f⁻¹(f(x)) = x` where `f⁻¹ ≠ f`

### Ancilla-Based Instructions

These require helper variables (ancillas):

1. **MUL** - Stores product in ancilla
2. **DIV** - Stores quotient and remainder
3. **AND** - Stores AND result in ancilla
4. **OR** - Stores OR result in ancilla

**Pattern**: Bennett's trick
- Initialize ancilla to 0
- Compute result into ancilla
- Use result
- Uncompute (restore ancilla to 0)

### Universal Gates

These can simulate quantum gates:

1. **Toffoli (CCNOT)** - Can be built with AND + XOR
2. **Fredkin (CSWAP)** - Can be built with SWAP + conditional

Both are **universal for reversible computation**!

---

## Performance Characteristics

### Complexity

| Instruction | Time | Space | Overhead |
|-------------|------|-------|----------|
| ADD/SUB | O(1) | O(1) | Minimal |
| MUL | O(1) | O(1) + ancilla | Low |
| DIV | O(1) | O(1) + 2 ancillas | Low |
| SWAP | O(1) | O(1) | Minimal |
| XOR/AND/OR | O(1) | O(1) | Minimal |
| ROL/ROR | O(1) | O(1) | Minimal |
| FLIP | O(1) | O(1) | Minimal |
| NEGATE | O(1) | O(1) | Minimal |
| NOOP | O(1) | O(1) | None |

All instructions execute in constant time!

### Memory Usage

- **Core instructions**: No extra memory
- **Ancilla-based**: Requires 1-2 extra variables
- **VM overhead**: ~10% for history tracking

---

## Advanced Topics

### Composing Instructions

Build complex operations from simple ones:

```rescript
// XOR-based swap (no SWAP instruction needed!)
let xorSwap = (a, b) => {
  XOR(a, b)  // a = a XOR b
  XOR(b, a)  // b = b XOR a (now b = original a)
  XOR(a, b)  // a = a XOR b (now a = original b)
}
```

### Toffoli Gate

Controlled-controlled-NOT:

```rescript
let toffoli = (a, b, c) => {
  let temp = 0
  AND(a, b, temp)  // temp = a AND b
  XOR(c, temp)     // if temp=1, flip c
  AND(a, b, temp)  // uncompute temp to 0
}
```

### Fredkin Gate

Controlled-SWAP:

```rescript
let fredkin = (control, a, b) => {
  // If control=1, swap a and b
  // Can be implemented with conditional SWAP
  if control == 1 {
    SWAP(a, b)
  }
}
```

---

## See Also

- **[API-REFERENCE.md](API-REFERENCE.md)** - Complete API documentation
- **[REVERSIBLE-COMPUTING-CONCEPTS.md](REVERSIBLE-COMPUTING-CONCEPTS.md)** - Theory deep dive
- **[BEGINNER-TUTORIAL.md](tutorials/BEGINNER-TUTORIAL.md)** - Getting started guide
- **[examples/](../examples/)** - Example programs

---

**Last Updated**: 2025-11-22
**Version**: 2.1.0
