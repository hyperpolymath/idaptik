# Development Workflow Guide

**How to contribute to Idaptik effectively**

## Quick Start for Contributors

### 1. Fork & Clone

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR_USERNAME/idaptiky
cd idaptiky

# Add upstream
git remote add upstream https://github.com/Hyperpolymath/idaptiky
```

### 2. Set Up Environment

```bash
# Install dependencies
curl -fsSL https://deno.land/install.sh | sh
npm install -g rescript
cargo install just  # or: sudo dnf install just

# Verify installation
just doctor
```

### 3. Create Feature Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create branch
git checkout -b feature/my-awesome-feature
```

### 4. Development Cycle

```bash
# Terminal 1: Watch mode
just watch

# Terminal 2: Test on every change
watch -n 2 just test

# Terminal 3: Your editor
code .  # or vim, emacs, etc.
```

### 5. Make Changes

Follow these principles:

- **One feature per branch**
- **Write tests first** (TDD)
- **Document as you go**
- **Commit frequently**

### 6. Test Everything

```bash
# Run full verification
just verify

# Or individually:
just build
just test
just lint
just rsr-verify
```

### 7. Commit & Push

```bash
# Stage changes
git add -A

# Commit with clear message
git commit -m "Add feature: description

- Detail 1
- Detail 2
- Fixes #123
"

# Push to your fork
git push origin feature/my-awesome-feature
```

### 8. Create Pull Request

```bash
# Using GitHub CLI
gh pr create --title "Add awesome feature" --body "Description..."

# Or via GitHub web interface
```

---

## Common Development Tasks

### Adding a New Instruction

**Example: Adding a MUL instruction**

1. **Create instruction file:**
   ```bash
   touch src/core/instructions/Mul.res
   ```

2. **Implement interface:**
   ```rescript
   // Mul.res
   let make = (varA: string, varB: string, varResult: string): Instruction.t => {
     instructionType: "MUL",
     args: [varA, varB, varResult],
     execute: state => {
       let a = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
       let b = Js.Dict.get(state, varB)->Belt.Option.getWithDefault(0)
       Js.Dict.set(state, varResult, a * b)
     },
     invert: state => {
       // Inverse requires division (not always reversible!)
       // Need auxiliary registers for true reversibility
       // This is a Bennett's method implementation
     },
   }
   ```

3. **Write tests:**
   ```bash
   touch tests/unit/instructions/mul_test.res
   ```

4. **Test reversibility:**
   ```rescript
   let testMulReversibility = (): bool => {
     // Verify execute(invert(state)) === state
   }
   ```

5. **Document:**
   Update `docs/API-REFERENCE.md` with MUL documentation.

6. **Commit:**
   ```bash
   git add src/core/instructions/Mul.res tests/unit/instructions/mul_test.res
   git commit -m "Add MUL instruction with reversibility"
   ```

### Creating a Puzzle

1. **Design puzzle:**
   Plan initial state, goal state, allowed instructions.

2. **Create JSON:**
   ```bash
   just create-puzzle my_new_puzzle
   ```

3. **Edit puzzle:**
   ```bash
   $EDITOR data/puzzles/my_new_puzzle.json
   ```

4. **Validate:**
   ```bash
   # Manual test
   just puzzle my_new_puzzle

   # Or (future):
   just validate-puzzle data/puzzles/my_new_puzzle.json
   ```

5. **Commit:**
   ```bash
   git add data/puzzles/my_new_puzzle.json
   git commit -m "Add puzzle: My New Puzzle

   - Difficulty: intermediate
   - Teaches: XOR swap trick
   - Optimal moves: 8
   "
   ```

### Writing Documentation

1. **Choose format:**
   - Tutorial: `docs/tutorials/NAME.md`
   - Guide: `docs/GUIDE-NAME.md`
   - Reference: `docs/API-REFERENCE.md`

2. **Follow template:**
   ```markdown
   # Title

   **One-line description**

   ## Overview
   ## Usage
   ## Examples
   ## See Also
   ```

3. **Add to README:**
   Link from main README.md if appropriate.

4. **Commit:**
   ```bash
   git add docs/tutorials/new-tutorial.md
   git commit -m "Add tutorial: New Tutorial Name"
   ```

### Running Benchmarks

```bash
# Run all benchmarks
just benchmark

# Profile specific operation
# (modify benchmarks/benchmark.res first)
just build
deno run --allow-read --v8-flags=--prof benchmarks/benchmark.res.js
```

---

## Code Style

### ReScript

```rescript
// Good
let createState = (~variables: array<string>, ~initialValue: int=0, ()): state => {
  let dict = Js.Dict.empty()
  Belt.Array.forEach(variables, var => {
    Js.Dict.set(dict, var, initialValue)
  })
  dict
}

// Bad
let createState = (variables,initialValue) => {
  let dict=Js.Dict.empty()
  Belt.Array.forEach(variables,var=>{Js.Dict.set(dict,var,initialValue)})
  dict
}
```

**Rules:**
- 2-space indentation
- Labeled arguments for clarity
- Descriptive variable names
- Comments for complex logic

### Commit Messages

```
type(scope): short description

Detailed explanation of what changed and why.

- Bullet points for specifics
- Reference issues: Fixes #123
- Breaking changes: BREAKING CHANGE: description
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `chore`: Build/tooling

---

## Testing Strategy

### Levels

1. **Unit Tests** - Individual instructions
2. **Integration Tests** - VM + instructions
3. **Property Tests** - Reversibility guarantee
4. **Benchmark Tests** - Performance regression

### Writing Good Tests

```rescript
// Test naming: test[What][Condition]
let testAddReversibility = (): bool => {
  // Arrange
  let state = State.createState(~variables=["x", "y"], ())
  let original = State.cloneState(state)

  // Act
  let instr = Add.make("x", "y")
  instr.execute(state)
  instr.invert(state)

  // Assert
  State.statesMatch(state, original)
}
```

---

## Debugging

### Common Issues

**"Cannot find module"**
```bash
just clean
just build
```

**Tests failing:**
```bash
# Run specific test
deno run --allow-read tests/unit/instructions/add_test.res.js

# Check test file directly
cat tests/unit/instructions/add_test.res
```

**Type errors:**
```bash
# ReScript compiler shows exact location
rescript build

# Check generated .res.js file
cat src/core/State.res.js
```

### Debug Workflow

1. **Add console logs:**
   ```rescript
   Js.Console.log("Debug: state =", state)
   ```

2. **Rebuild:**
   ```bash
   just build
   ```

3. **Run:**
   ```bash
   deno run --allow-read src/CLI.res.js demo
   ```

4. **Remove logs** before committing

---

## Release Process

### Version Numbers

Follow **Semantic Versioning**:
- **Major**: Breaking changes (v2.0.0 → v3.0.0)
- **Minor**: New features (v2.1.0 → v2.2.0)
- **Patch**: Bug fixes (v2.1.1 → v2.1.2)

### Release Checklist

```bash
# 1. Update version
$EDITOR rescript.json  # Update version field
$EDITOR package.json   # Update version field

# 2. Update CHANGELOG.md
$EDITOR CHANGELOG.md

# 3. Run full verification
just ci
just rsr-verify

# 4. Commit version bump
git add rescript.json package.json CHANGELOG.md
git commit -m "chore: bump version to v2.1.0"

# 5. Tag release
git tag -a v2.1.0 -m "Release v2.1.0"

# 6. Push
git push origin main --tags

# 7. Create GitHub release
gh release create v2.1.0 --title "v2.1.0" --notes "See CHANGELOG.md"
```

---

## Getting Help

### Resources

- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Contribution guidelines
- **[CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)** - Community standards
- **[API-REFERENCE.md](API-REFERENCE.md)** - Technical documentation
- **[GRAND-VISION-MAP.md](../GRAND-VISION-MAP.md)** - Project roadmap

### Community

- **GitHub Discussions** - Ask questions
- **Issues** - Report bugs, request features
- **Pull Requests** - Submit contributions

### Office Hours

(Future) Monthly maintainer office hours for questions and guidance.

---

## Tips for Success

1. **Start Small** - Begin with good first issues
2. **Ask Questions** - No question is too basic
3. **Read Code** - Learn from existing implementations
4. **Test Thoroughly** - Reversibility must be perfect
5. **Document** - Future you (and others) will thank you
6. **Be Patient** - Code review takes time
7. **Have Fun!** - Reversible computing is fascinating

---

**Happy contributing!** 🚀

*You're helping build the future of reversible computing.*
