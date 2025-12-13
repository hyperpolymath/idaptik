# Puzzle Creation Guide

**Create Your Own Reversible Computing Puzzles**

This guide teaches you how to design, test, and share puzzles for Idaptik.

---

## Puzzle Anatomy

Every puzzle is a JSON file with this structure:

```json
{
  "name": "Puzzle Name",
  "description": "What the solver needs to do",
  "difficulty": "beginner|intermediate|advanced|expert",
  "initialState": { "var1": value1, "var2": value2 },
  "goalState": { "var1": goalValue1, "var2": goalValue2 },
  "maxMoves": 20,
  "optimalMoves": 8,
  "allowedInstructions": ["ADD", "SUB", "SWAP"],
  "hints": [
    { "moveNumber": 5, "text": "Hint after 5 moves" }
  ],
  "metadata": {
    "author": "Your Name",
    "created": "2025-11-22",
    "tags": ["arithmetic", "beginner"]
  }
}
```

---

## Step-by-Step Creation

### 1. Choose a Concept

Good puzzle concepts:
- **Mathematical:** Fibonacci, primes, GCD
- **Algorithmic:** Sorting, searching, swapping
- **Classic:** Towers of Hanoi, magic squares
- **Bitwise:** XOR cipher, bit manipulation
- **Creative:** Custom challenges

### 2. Design Initial State

```json
"initialState": {
  "x": 10,
  "y": 5,
  "temp": 0
}
```

**Tips:**
- Use descriptive variable names (not just a, b, c)
- Include helper variables (temp, counter, etc.)
- Start simple for beginners
- Complex states for experts

### 3. Define Goal State

```json
"goalState": {
  "x": 15,
  "y": 5,
  "temp": 0
}
```

**Must:**
- Be reachable from initial state
- Use same variables as initial state
- Have a unique solution (or document multiple solutions)

### 4. Test Solvability

**Manual Test:**
1. Write down initial state
2. Try to reach goal using allowed instructions
3. Count moves
4. Can you reach it? If not, revise!

**Automated Test (Future):**
```bash
just validate-puzzle my_puzzle.json
```

### 5. Set Difficulty

| Difficulty | Moves | Complexity | Audience |
|------------|-------|------------|----------|
| **Beginner** | 1-5 | Single concept | New users |
| **Intermediate** | 5-15 | Multiple steps | Comfortable |
| **Advanced** | 15-30 | Complex sequences | Experienced |
| **Expert** | 30+ or optimal=hard | Optimization | Masters |

### 6. Add Hints

```json
"hints": [
  { "moveNumber": 0, "text": "Start with..." },
  { "moveNumber": 5, "text": "Halfway there!" },
  { "moveNumber": 10, "text": "Try using SWAP..." }
]
```

**Hint Guidelines:**
- First hint at moveNumber=0 (starting tip)
- Add hints every 5-10 moves for longer puzzles
- Don't give away the solution!
- Progressive difficulty

---

## Example Puzzles by Type

### Type 1: Single Instruction

**Goal:** Teach one instruction

```json
{
  "name": "Learn SWAP",
  "description": "Exchange two values",
  "difficulty": "beginner",
  "initialState": { "a": 10, "b": 20 },
  "goalState": { "a": 20, "b": 10 },
  "maxMoves": 3,
  "optimalMoves": 1,
  "allowedInstructions": ["SWAP"]
}
```

### Type 2: Sequence

**Goal:** Multiple operations in order

```json
{
  "name": "Chain Operations",
  "description": "Add, then swap, then negate",
  "difficulty": "intermediate",
  "initialState": { "x": 5, "y": 3, "z": 0 },
  "goalState": { "x": 0, "y": -3, "z": 8 },
  "maxMoves": 10,
  "optimalMoves": 3,
  "allowedInstructions": ["ADD", "SWAP", "NEGATE"]
}
```

### Type 3: Algorithm

**Goal:** Implement an algorithm

```json
{
  "name": "GCD via Euclid",
  "description": "Find greatest common divisor of 48 and 18",
  "difficulty": "advanced",
  "initialState": { "a": 48, "b": 18, "gcd": 0 },
  "goalState": { "a": 0, "b": 0, "gcd": 6 },
  "maxMoves": 40,
  "optimalMoves": 18,
  "allowedInstructions": ["ADD", "SUB", "SWAP"]
}
```

### Type 4: Optimization

**Goal:** Reach goal in minimal moves

```json
{
  "name": "Efficiency Challenge",
  "description": "Reach the goal in exactly 5 moves",
  "difficulty": "expert",
  "initialState": { "x": 0, "y": 0 },
  "goalState": { "x": 100, "y": 50 },
  "maxMoves": 5,
  "optimalMoves": 5,
  "allowedInstructions": ["ADD", "SUB"]
}
```

---

## Puzzle Design Patterns

### Pattern 1: Value Transfer

Move a value from one variable to another.

```
Initial: a=10, b=0
Goal:    a=0, b=10
Solution: SWAP a b
```

### Pattern 2: Accumulator

Build up a value incrementally.

```
Initial: sum=0, values=[1,2,3,4,5]
Goal:    sum=15
Solution: ADD sum to each value
```

### Pattern 3: State Machine

Variables represent states, transitions move between them.

```
Initial: state=0, ...
Goal:    state=3
Solution: Sequence of operations changing state
```

### Pattern 4: Reversibility Proof

Execute operations, then undo to return to start.

```
Initial: a=7, b=13
Goal:    a=7, b=13  (same as initial!)
Solution: Do complex operations, then reverse them all
```

---

## Testing Your Puzzle

### Checklist

- [ ] Initial state is clear and simple
- [ ] Goal state is reachable
- [ ] maxMoves is generous (1.5x optimal)
- [ ] optimalMoves is correct (tested manually)
- [ ] Difficulty matches complexity
- [ ] Hints are helpful but not spoilers
- [ ] Instructions are sufficient
- [ ] JSON is valid (use jsonlint.com)

### Manual Solve

1. Print initial state on paper
2. Write each move
3. Track state after each move
4. Count total moves
5. Did you reach the goal?

### Automated Validation (Future)

```bash
just validate-puzzle my_puzzle.json
# Checks:
# - JSON syntax
# - Solvability
# - Optimal moves
# - Hint placement
```

---

## Sharing Your Puzzle

### 1. Create File

```bash
# Name format: difficulty_##_short_name.json
# Examples:
# beginner_01_my_puzzle.json
# intermediate_05_fibonacci.json
# expert_03_quantum_sim.json
```

### 2. Add to Collection

```bash
cp my_puzzle.json idaptiky/data/puzzles/
```

### 3. Test It

```bash
just puzzle my_puzzle
```

### 4. Contribute

```bash
git add data/puzzles/my_puzzle.json
git commit -m "Add puzzle: My Puzzle Name"
git push
# Open pull request on GitHub
```

---

## Advanced: Programmatic Puzzles

Generate puzzles from code:

```javascript
// generate_puzzle.js
const puzzle = {
  name: `Fibonacci ${n}`,
  initialState: { a: 0, b: 1, result: 0 },
  goalState: { result: fibonacci(n) },
  // ... rest of puzzle
};

console.log(JSON.stringify(puzzle, null, 2));
```

---

## Puzzle Categories

### 📚 Educational
- Teach specific instructions
- Introduce concepts
- Progressive difficulty

### 🎯 Challenge
- Optimization problems
- Minimal move count
- Multiple solutions

### 🧩 Classic
- Famous CS problems
- Mathematical puzzles
- Algorithm implementations

### 🎨 Creative
- Artistic patterns
- Unique mechanics
- Experimental concepts

---

## Tips for Great Puzzles

### DO ✅
- Start simple, build complexity
- Test thoroughly before sharing
- Write clear descriptions
- Provide helpful hints
- Credit sources if adapting puzzles

### DON'T ❌
- Make impossible puzzles
- Use unclear variable names
- Skip testing
- Spoil the solution in description
- Forget to set difficulty

---

## Example: Building a Puzzle from Scratch

Let's create "Double Trouble" step-by-step:

### 1. Concept
Teach doubling using only ADD (no multiplication).

### 2. Initial State
```json
"initialState": { "x": 7, "helper": 7 }
```

### 3. Goal
```json
"goalState": { "x": 14, "helper": 7 }
```

### 4. Solution
```
ADD x helper  // x = 7 + 7 = 14
```

### 5. Constraints
```json
"maxMoves": 8,
"optimalMoves": 1,
"allowedInstructions": ["ADD", "SUB", "SWAP"]
```

### 6. Hints
```json
"hints": [
  { "moveNumber": 0, "text": "How do you add a number to itself?" },
  { "moveNumber": 3, "text": "You might need a helper variable!" }
]
```

### 7. Final Puzzle
```json
{
  "name": "Double Trouble",
  "description": "Double a number using only ADD",
  "difficulty": "intermediate",
  "initialState": { "x": 7, "helper": 7 },
  "goalState": { "x": 14, "helper": 7 },
  "maxMoves": 8,
  "optimalMoves": 1,
  "allowedInstructions": ["ADD", "SUB", "SWAP"],
  "hints": [
    { "moveNumber": 0, "text": "How do you add a number to itself?" },
    { "moveNumber": 3, "text": "You might need a helper variable!" }
  ],
  "metadata": {
    "author": "Idaptik Team",
    "created": "2025-11-22",
    "tags": ["arithmetic", "doubling"]
  }
}
```

---

## Resources

- **[JSON Schema](../schemas/puzzle.schema.json)** - Formal puzzle format
- **[Example Puzzles](../../data/puzzles/)** - 24+ examples
- **[BEGINNER-TUTORIAL.md](BEGINNER-TUTORIAL.md)** - Solving puzzles
- **[Community Puzzles](https://puzzles.idaptik.dev)** - Browse & share

---

## Get Help

- **Discord:** #puzzle-creation channel
- **Forum:** puzzles.idaptik.dev/create
- **GitHub:** Open an issue for feedback

---

**Now go create amazing puzzles!** 🎉

*Your puzzle could teach thousands of people about reversible computing.*
