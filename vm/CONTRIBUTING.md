# Contributing to Idaptik Reversible VM

Thank you for your interest in contributing to Idaptik! This document provides guidelines for contributing to the project.

## 📜 Code of Conduct

This project follows the principles of respectful collaboration:

- Be kind and courteous
- Respect different viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

## 🎯 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include:

- **Clear title** - Descriptive and specific
- **Steps to reproduce** - Detailed sequence that triggers the bug
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Environment** - OS, Deno version, ReScript version
- **Additional context** - Screenshots, error messages, logs

**Example:**
```
Title: VM crashes on NEGATE instruction with negative values

Steps:
1. Create state with x=-5
2. Run NEGATE instruction on x
3. VM crashes with stack overflow

Expected: x should become 5
Actual: Stack overflow error

Environment:
- OS: Linux (Fedora 43)
- Deno: 2.1.0
- ReScript: 11.0.0
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide step-by-step description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List some examples** of how it would be used
- **Consider alternatives** you've considered

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** following the code style guidelines
3. **Add tests** if applicable
4. **Update documentation** if needed
5. **Ensure tests pass** (`just test`)
6. **Submit a pull request**

## 🛠️ Development Setup

### Prerequisites

```bash
# Install Deno
curl -fsSL https://deno.land/install.sh | sh

# Install ReScript compiler
npm install -g rescript

# Install Just task runner
cargo install just
```

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/idaptik-reversible.git
cd idaptik-reversible

# Check dependencies
just doctor

# Build project
just build

# Run tests
just test

# Run demo
just demo
```

### Development Workflow

```bash
# Start watch mode (auto-rebuild)
just watch

# In another terminal, run tests
just test

# Format code
just format

# Lint code
just lint

# Full verification
just verify
```

## 📝 Code Style

### ReScript Style

- Use **2-space indentation**
- Use **descriptive variable names**
- Use **pattern matching** over if/else where appropriate
- Add **type annotations** for public functions
- Keep functions **small and focused**

**Example:**
```rescript
// Good
let calculateSum = (numbers: array<int>): int => {
  numbers->Belt.Array.reduce(0, (acc, n) => acc + n)
}

// Avoid
let calc = (x) => x->Belt.Array.reduce(0, (a, b) => a + b)
```

### Formatting

Run `just format` before committing to ensure consistent formatting.

### Comments

- Write **clear, concise comments** explaining "why", not "what"
- Use **doc comments** for public APIs
- Add **TODO comments** with your name for future work

**Example:**
```rescript
// Calculate the inverse operation for undo functionality
// This is critical for maintaining reversibility guarantees
let invert = (state: Js.Dict.t<int>): unit => {
  // Implementation
}
```

## 🧪 Testing

### Writing Tests

Add tests for new instructions in `src/CLI.res` or create a dedicated test file:

```rescript
let testMyInstruction = (): unit => {
  let state = State.createState(~variables=["x"], ~initialValue=0)

  // Test forward execution
  let instr = MyInstruction.make("x")
  instr.execute(state)

  // Verify result
  let result = Js.Dict.get(state, "x")->Belt.Option.getWithDefault(0)
  if result == expectedValue {
    logSuccess("✓ MyInstruction test passed")
  } else {
    logError("✗ MyInstruction test failed")
  }

  // Test inverse
  instr.invert(state)
  let reverted = Js.Dict.get(state, "x")->Belt.Option.getWithDefault(0)
  if reverted == 0 {
    logSuccess("✓ MyInstruction invert test passed")
  } else {
    logError("✗ MyInstruction invert test failed")
  }
}
```

### Running Tests

```bash
# Run all tests
just test

# Build and test
just verify

# Full CI pipeline
just ci
```

## 📚 Documentation

### Code Documentation

- Add **doc comments** to public functions
- Update **README** if adding major features
- Update **CHANGELOG.md** following Keep a Changelog format

### README Updates

When adding features, update:
- Feature list
- Usage examples
- Command reference (if applicable)

### CHANGELOG Updates

Follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [Unreleased]

### Added
- New XOR instruction for bitwise operations
- Performance benchmark suite

### Changed
- Improved error messages in VM

### Fixed
- Bug in SWAP instruction with identical registers
```

## 🏗️ Project Structure

```
idaptik-reversible/
├── src/
│   ├── core/
│   │   ├── Instruction.res      # Core types
│   │   ├── State.res            # State management
│   │   ├── VM.res               # Virtual machine
│   │   └── instructions/        # Instruction implementations
│   │       ├── Add.res
│   │       ├── Sub.res
│   │       ├── Swap.res
│   │       ├── Negate.res
│   │       └── Noop.res
│   └── CLI.res                  # CLI interface
├── data/
│   └── puzzles/                 # Puzzle definitions
├── rescript.json                # ReScript config
├── deno.json                    # Deno config
└── justfile                     # Build system
```

## 🎨 Adding New Instructions

To add a new reversible instruction:

1. **Create the instruction file:**
```rescript
// src/core/instructions/MyInstruction.res

let make = (arg: string): Instruction.t => {
  instructionType: "MYINSTR",
  args: [arg],
  execute: state => {
    // Forward operation
    let val = Js.Dict.get(state, arg)->Belt.Option.getWithDefault(0)
    Js.Dict.set(state, arg, /* transform val */)
  },
  invert: state => {
    // Reverse operation - must undo execute perfectly!
    let val = Js.Dict.get(state, arg)->Belt.Option.getWithDefault(0)
    Js.Dict.set(state, arg, /* reverse transform val */)
  },
}
```

2. **Add tests in CLI.res**

3. **Update documentation:**
   - Add to instruction table in README
   - Add to CHANGELOG.md under Unreleased

4. **Verify reversibility:**
   - Execute then invert must return to original state
   - Add comprehensive tests

## 🔄 Reversibility Guidelines

**Critical:** Every instruction MUST be perfectly reversible.

### Testing Reversibility

```rescript
// Original state
let original = State.cloneState(state)

// Execute instruction
instr.execute(state)

// Invert instruction
instr.invert(state)

// MUST be true
State.statesMatch(state, original)
```

### Common Pitfalls

❌ **Don't:**
```rescript
// Information loss - not reversible!
execute: state => {
  let val = Js.Dict.get(state, "x")->Belt.Option.getWithDefault(0)
  Js.Dict.set(state, "x", val / 2)  // Integer division loses info
}
```

✅ **Do:**
```rescript
// Reversible operation
execute: state => {
  let val = Js.Dict.get(state, "x")->Belt.Option.getWithDefault(0)
  Js.Dict.set(state, "x", val * 2)  // Can be undone with div
}
```

## 📄 Licensing

By contributing, you agree that your contributions will be licensed under the project's dual MIT + Palimpsest License v0.8. You may choose either license for your own use.

### License Header

Add to new files:
```rescript
// Copyright (c) 2024 Joshua & Jonathan Jewell
// Licensed under MIT OR Palimpsest License v0.8
// See LICENSE and LICENSE-PALIMPSEST.txt for details
```

## 🤝 Community

### Getting Help

- **Documentation:** See README.md, MIGRATION-GUIDE.md
- **Commands:** Run `just help`
- **Issues:** Check existing issues or create new one

### Recognition

Contributors are recognized in:
- Git commit history
- Release notes
- CHANGELOG.md (for significant contributions)

## 🎯 Good First Issues

Looking for a place to start? Check issues labeled:
- `good-first-issue` - Beginner-friendly
- `help-wanted` - We need help with these
- `documentation` - Documentation improvements

### Suggested First Contributions

1. **Add new instructions** (XOR, ROL, ROR)
2. **Improve error messages** in CLI
3. **Add more puzzles** in data/puzzles/
4. **Enhance documentation** with examples
5. **Write tests** for edge cases

## ✅ Pull Request Checklist

Before submitting:

- [ ] Code follows ReScript style guidelines
- [ ] Code is formatted (`just format`)
- [ ] All tests pass (`just test`)
- [ ] Linter passes (`just lint`)
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated (if adding features)
- [ ] Commit messages are clear and descriptive
- [ ] No merge conflicts with main
- [ ] PR description explains what and why

## 🚀 Release Process

(For maintainers)

1. Update version in CHANGELOG.md
2. Create release commit
3. Tag with version: `git tag v2.1.0`
4. Push with tags: `git push --tags`
5. Create GitHub release with notes

---

Thank you for contributing to Idaptik! 🎉

**Questions?** Open an issue or reach out to the maintainers.
