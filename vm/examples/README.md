# Idaptik Examples

**Sample programs demonstrating reversible computing concepts**

## Running Examples

Each example is a ReScript program. To run:

```bash
# Compile ReScript files
just build

# Run example (when implemented)
deno run --allow-read examples/01_hello_reversible.res.js
```

---

## Example Programs

### 01: Hello Reversible World
**File:** `01_hello_reversible.res`
**Concepts:** Basic ADD, perfect reversibility

Demonstrates the core concept: execute forward, undo backward, return to original state.

### 02: Fibonacci Sequence
**File:** `02_fibonacci.res`
**Concepts:** Iterative computation, state management

Generate Fibonacci numbers using only reversible ADD, SUB, and SWAP operations.

### 03: XOR Swap Trick
**File:** `03_xor_swap.res`
**Concepts:** Bitwise operations, XOR properties

Classic computer science algorithm: swap two variables without a temp variable using XOR.

### 04: GCD (Euclidean Algorithm)
**File:** `04_gcd_euclidean.res`
**Concepts:** Algorithms, loops, modulo via subtraction

Find greatest common divisor using the Euclidean algorithm implemented with reversible operations.

### 05: Sorting Network
**File:** `05_sorting_network.res`
**Concepts:** Conditional operations, comparison, sorting

Sort three numbers using a reversible sorting network (compare-and-swap).

---

## Key Concepts Demonstrated

### Reversibility
Every example can be run backward to restore the initial state perfectly.

### Integer Arithmetic
All operations work on integer values (no floating point).

### State Transformation
Each example shows how state evolves through a sequence of reversible operations.

### Algorithm Implementation
Classic algorithms adapted to use only reversible operations.

---

## Next Steps

- Modify examples to see how they work
- Create your own example programs
- Combine concepts from multiple examples
- Share your creations with the community

---

## Additional Resources

- **[BEGINNER-TUTORIAL.md](../docs/tutorials/BEGINNER-TUTORIAL.md)** - Learn Idaptik
- **[PUZZLE-CREATION-GUIDE.md](../docs/tutorials/PUZZLE-CREATION-GUIDE.md)** - Create puzzles
- **[API-REFERENCE.md](../docs/API-REFERENCE.md)** - Full documentation

---

**Happy reversible programming!** 🔄
