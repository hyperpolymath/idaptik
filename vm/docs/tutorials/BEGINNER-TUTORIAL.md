# Beginner Tutorial: Your First 10 Minutes with Idaptik

**Welcome to Idaptik!** This tutorial will get you from zero to solving puzzles in reversible computing.

## What is Reversible Computing?

Imagine if every action in a program could be **perfectly undone** - like pressing Ctrl+Z, but for computer instructions! That's reversible computing.

### The Magic

```
Forward:  x=5  →  [ADD x 3]  →  x=8
Reverse:  x=8  ←  [UNDO]     ←  x=5  (perfectly restored!)
```

Every instruction in Idaptik can be reversed without losing information.

---

## Prerequisites

You'll need three tools installed:

1. **Deno** - JavaScript runtime
   ```bash
   curl -fsSL https://deno.land/install.sh | sh
   ```

2. **ReScript** - Type-safe compiler
   ```bash
   npm install -g rescript
   ```

3. **Just** - Task runner
   ```bash
   cargo install just
   # OR on Fedora: sudo dnf install just
   ```

---

## Step 1: Clone & Build (2 minutes)

```bash
# Clone the repository
git clone https://github.com/Hyperpolymath/idaptiky
cd idaptiky

# Check everything is installed
just doctor

# Build the project
just build
```

**Expected output:**
```
✓ Deno found
✓ ReScript compiler found
✓ Build successful!
```

---

## Step 2: Run Your First Demo (1 minute)

```bash
just demo
```

**What you'll see:**
```
[INFO] Starting reversible VM demo...
[INFO] Initial state: x=5, y=3, z=0
[INFO] Executing: ADD x y (x = x + y)
Current State: { x: 8, y: 3, z: 0 }
[INFO] Executing: SWAP x z
Current State: { x: 0, y: 3, z: 8 }
[INFO] Executing: NEGATE y
Current State: { x: 0, y: -3, z: 8 }

[INFO] Now reversing operations...
[INFO] Undoing NEGATE y
Current State: { x: 0, y: 3, z: 8 }
[INFO] Undoing SWAP x z
Current State: { x: 8, y: 3, z: 0 }
[INFO] Undoing ADD x y
Current State: { x: 5, y: 3, z: 0 }

[SUCCESS] Demo complete! Notice how undo perfectly reversed all operations.
```

🎉 **You just saw reversible computing in action!**

---

## Step 3: Understanding Instructions (3 minutes)

Idaptik has 9 core instructions. Let's learn them:

### Arithmetic

**ADD a b** - Add b to a
```
Before: a=10, b=5
After:  a=15, b=5
Undo:   a=10, b=5  (perfectly restored!)
```

**SUB a b** - Subtract b from a
```
Before: a=10, b=3
After:  a=7, b=3
Undo:   a=10, b=3
```

### Data Movement

**SWAP a b** - Exchange values
```
Before: a=10, b=20
After:  a=20, b=10
Undo:   a=10, b=20  (swap is self-inverse!)
```

### Sign

**NEGATE a** - Flip sign
```
Before: a=10
After:  a=-10
Undo:   a=10  (negate is self-inverse!)
```

### Bitwise (New!)

**XOR a b** - Bitwise exclusive OR
```
Before: a=12 (0b1100), b=10 (0b1010)
After:  a=6  (0b0110), b=10
Undo:   a=12, b=10  (XOR is self-inverse!)
```

**FLIP a** - Bitwise NOT
```
Before: a=5 (0b0101)
After:  a=-6 (0b1010 in two's complement)
Undo:   a=5  (FLIP is self-inverse!)
```

**ROL a** - Rotate bits left
```
Before: a=0b0011 (3)
After:  a=0b0110 (6)
Undo:   a=0b0011 (use ROR to reverse)
```

**ROR a** - Rotate bits right
```
Before: a=0b0110 (6)
After:  a=0b0011 (3)
Undo:   a=0b0110 (use ROL to reverse)
```

### Utility

**NOOP** - Do nothing
```
Before: a=10
After:  a=10
Undo:   a=10  (no change!)
```

---

## Step 4: Solve Your First Puzzle (4 minutes)

Let's solve "Simple Addition" - your first reversible puzzle!

### The Challenge

```json
{
  "name": "Simple Addition",
  "initialState": { "x": 5, "y": 3, "z": 0 },
  "goalState": { "x": 8, "y": 3, "z": 0 },
  "maxMoves": 5
}
```

**Goal:** Get x from 5 to 8 using ADD.

### Solution

```bash
# List all puzzles
just list-puzzles

# Run the puzzle (when implemented)
just puzzle beginner_01_simple_add
```

**Steps:**
1. Current state: x=5, y=3, z=0
2. Execute: `ADD x y`
3. New state: x=8, y=3, z=0 ✓ GOAL REACHED!

**Congratulations!** You solved it in 1 move (optimal: 1 move) 🎉

---

## Step 5: Try More Puzzles

### Beginner Puzzles (Start Here!)

1. **Simple Addition** - Learn ADD
2. **Swap Meet** - Learn SWAP
3. **Sign Flip** - Learn NEGATE
4. **Road to Zero** - Subtraction practice

### Intermediate Puzzles (Once Comfortable)

5. **Double Trouble** - Double a number
6. **Chain Reaction** - Propagate values
7. **Balance Scale** - Redistribute values
8. **Fibonacci Start** - Generate sequence

### Advanced Puzzles (Challenge!)

9. **Three-Way Rotation** - Rotate three values
10. **XOR Swap Trick** - Classic CS algorithm
11. **Magic Square** - Arrange numbers

---

## Key Concepts

### Reversibility

Every instruction **must** be reversible:
- Forward: `execute(state)`
- Backward: `invert(state)`
- Property: `invert(execute(state)) === state`

### Why It Matters

1. **Debugging** - Step backward through execution
2. **Undo Systems** - Perfect undo/redo
3. **Quantum Computing** - Quantum gates are reversible
4. **Energy Efficiency** - Reversible circuits use less energy (Landauer's principle)

---

## Next Steps

### Write Your First Program

Create a file `my_program.ida`:
```
ADD x y
SWAP x z
NEGATE y
```

### Build a Puzzle

Create `my_puzzle.json`:
```json
{
  "name": "My First Puzzle",
  "description": "Reach the goal!",
  "initialState": { "a": 0, "b": 10 },
  "goalState": { "a": 10, "b": 0 },
  "maxMoves": 5,
  "allowedInstructions": ["ADD", "SUB", "SWAP"]
}
```

### Learn More

- **[PUZZLE-GUIDE.md](PUZZLE-GUIDE.md)** - Create your own puzzles
- **[API-REFERENCE.md](API-REFERENCE.md)** - Full documentation
- **[GRAND-VISION-MAP.md](../GRAND-VISION-MAP.md)** - Project roadmap
- **[Examples](../examples/)** - Sample programs

---

## Troubleshooting

### Build Fails

```bash
just clean
just build
```

### Tests Fail

```bash
just test
# Check which instructions are failing
```

### Command Not Found

```bash
# Make sure you're in the idaptiky directory
cd /path/to/idaptiky

# Verify tools are installed
just doctor
```

---

## Community

- **GitHub:** https://github.com/Hyperpolymath/idaptiky
- **Issues:** Report bugs and request features
- **Discussions:** Ask questions and share ideas

---

## Summary

In 10 minutes, you've:

✅ Installed Idaptik
✅ Run your first demo
✅ Learned 9 reversible instructions
✅ Solved your first puzzle
✅ Understood reversibility

**You're now a reversible computing beginner!** 🎓

Next: Try solving all beginner puzzles, then move to intermediate challenges.

---

**Happy reversible computing!** 🔄

*Questions? See [CONTRIBUTING.md](../../CONTRIBUTING.md) or open a GitHub issue.*
