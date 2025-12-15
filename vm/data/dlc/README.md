# DLC Content for Idaptik Reversible VM

Downloadable content packs for the reversible computing puzzle system.

## Directory Structure

```
dlc/
├── README.md           # This file
├── manifest.json       # DLC registry and metadata
└── packs/              # Individual DLC packs
    ├── quantum-gates/  # Quantum computing puzzles
    ├── crypto-ops/     # Cryptography puzzles
    └── ...
```

## DLC Pack Format

Each DLC pack is a directory containing:

```
pack-name/
├── manifest.json       # Pack metadata
├── puzzles/            # Puzzle definitions
│   ├── puzzle_01.json
│   └── ...
└── README.md           # Pack documentation
```

### Pack Manifest Schema

```json
{
  "id": "quantum-gates",
  "name": "Quantum Gates Pack",
  "version": "1.0.0",
  "description": "Implement quantum gates using reversible operations",
  "author": "IDApTIK Team",
  "difficulty": "expert",
  "puzzles": [
    "toffoli_gate",
    "fredkin_gate",
    "cnot_gate"
  ],
  "requires": {
    "vm_version": ">=2.0.0",
    "instructions": ["XOR", "AND", "SWAP"]
  },
  "tags": ["quantum", "gates", "advanced"]
}
```

## Creating a DLC Pack

1. Create a directory in `packs/` with your pack name
2. Add a `manifest.json` with pack metadata
3. Create puzzles in `puzzles/` subdirectory
4. Add a README documenting the pack

### Example Puzzle (quantum-gates/puzzles/toffoli.json)

```json
{
  "name": "Toffoli Gate (CCNOT)",
  "description": "Implement the Toffoli gate - a universal reversible gate",
  "difficulty": "expert",
  "initialState": {
    "a": 1,
    "b": 1,
    "c": 0,
    "temp": 0
  },
  "goalState": {
    "a": 1,
    "b": 1,
    "c": 1,
    "temp": 0
  },
  "maxMoves": 10,
  "optimalMoves": 5,
  "allowedInstructions": ["AND", "XOR"],
  "hints": [
    {
      "moveNumber": 0,
      "text": "Toffoli flips c if both a AND b are 1"
    },
    {
      "moveNumber": 3,
      "text": "Use temp to store intermediate AND result"
    }
  ]
}
```

## Installing DLC

```bash
# List available DLC
just dlc-list

# Install a pack
just dlc-install quantum-gates

# Run a DLC puzzle
just puzzle quantum-gates:toffoli
```

## Integration with Main Game

DLC puzzles integrate with the main IDApTIK multiplayer game as:

- **Solo challenges** - Practice mode for reversible computing
- **Competitive puzzles** - Race to solve puzzles fastest
- **Cooperative puzzles** - Hacker/Infiltrator work together

## License

DLC content follows the same dual licensing as the main project:
- MIT License
- Palimpsest License v0.8

See the main project LICENSE files for details.
