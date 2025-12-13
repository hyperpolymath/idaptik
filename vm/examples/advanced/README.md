# Advanced Examples

**Cutting-edge reversible computing applications**

## Examples

### 01: Quantum SWAP Gate
**File:** `01_quantum_swap_gate.res`
**Concepts:** Quantum gates, Fredkin gate, quantum computing

Simulates quantum SWAP gates using reversible XOR operations. Demonstrates the connection between reversible computing and quantum algorithms.

### 02: Reversible Encryption
**File:** `02_reversible_encryption.res`
**Concepts:** XOR cipher, encryption/decryption, perfect secrecy

Implements a reversible encryption scheme using XOR. Shows how reversibility is fundamental to cryptography.

## Running Advanced Examples

```bash
# Compile all examples
just build

# Run quantum simulation
deno run --allow-read examples/advanced/01_quantum_swap_gate.res.js

# Run encryption demo
deno run --allow-read examples/advanced/02_reversible_encryption.res.js
```

## Learning Path

1. **Start with basic examples** (in `examples/`)
2. **Complete beginner tutorial** (`docs/tutorials/BEGINNER-TUTORIAL.md`)
3. **Solve intermediate puzzles**
4. **Try advanced examples** (you are here!)
5. **Read research papers** (see `GRAND-VISION-MAP.md`)

## Topics Covered

- **Quantum Computing** - Gate simulation
- **Cryptography** - XOR ciphers, one-time pads
- **Information Theory** - Landauer's principle
- **Algorithms** - Reversible implementations

## Next Steps

- Implement your own quantum algorithm
- Create reversible hash functions
- Build blockchain prototypes
- Contribute to Idaptik research

## Resources

- **[Grand Vision Map](../../GRAND-VISION-MAP.md)** - Future quantum features
- **[Academic Papers](../../docs/academic-papers.md)** - Research directions
- **[API Reference](../../docs/API-REFERENCE.md)** - Implementation details

---

**These examples are educational - not production cryptography!**
