# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Puzzle loader system (planned)
- Additional complex instructions (XOR, ROL, ROR)
- Web interface using Deno Fresh
- Visual debugger with step-through
- Puzzle editor
- Performance benchmarks

## [2.0.0] - 2025-11-21

### Changed
- **BREAKING:** Complete rewrite from Bun + TypeScript to Deno + ReScript
- **BREAKING:** Removed all npm/bun/typescript dependencies
- **BREAKING:** New build system using Just instead of npm scripts
- Improved type safety with ReScript's sound type system
- Enhanced security with Deno's explicit permission system

### Added
- ReScript implementation of core VM (9 .res files)
- Comprehensive CLI with demo, test, and help commands
- 600+ line Justfile with 40+ build recipes
- Dual MIT + Palimpsest v0.8 licensing
- Complete documentation suite (1500+ lines)
- MIGRATION-GUIDE.md for conversion reference
- CONVERSION-SUMMARY.md with technical details
- .editorconfig for consistent code formatting
- CONTRIBUTING.md for contribution guidelines

### Removed
- TypeScript source files (backed up in _old_typescript/)
- package.json and npm dependencies
- bun.lock
- tsconfig.json files
- node_modules directory (~100MB)

### Fixed
- Type safety issues now prevented at compile time
- Runtime errors eliminated with ReScript's type system

## [1.0.0] - 2024-XX-XX

### Added
- Initial TypeScript implementation
- Core VM with 5 instructions (ADD, SUB, SWAP, NEGATE, NOOP)
- Reversible computation engine
- Basic CLI interface
- Puzzle system with JSON definitions
- AGPL-3.0 license

### Implemented
- Instruction execution and inversion
- State management
- History tracking for undo/redo
- Puzzle definitions (vault_7, vault_defuse)

---

## Version History

### Version 2.0.0 (Deno + ReScript)
- **Technology:** Deno runtime, ReScript language
- **Dependencies:** Zero runtime dependencies
- **Build:** Just task runner
- **Status:** Production ready

### Version 1.0.0 (Bun + TypeScript)
- **Technology:** Bun runtime, TypeScript language
- **Dependencies:** 15+ npm packages
- **Build:** npm scripts
- **Status:** Superseded by v2.0.0

---

## Upgrade Notes

### Migrating from 1.x to 2.x

Version 2.0.0 is a complete rewrite with breaking changes. See MIGRATION-GUIDE.md for detailed upgrade instructions.

**Key Changes:**
- New runtime: Bun → Deno
- New language: TypeScript → ReScript
- New build system: npm → Just
- New licensing: AGPL-3.0 → Dual MIT + Palimpsest

**Migration Steps:**
1. Install Deno and ReScript
2. Install Just task runner
3. Run `just build` to compile
4. Run `just demo` to verify

**Compatibility:**
- Puzzle JSON format unchanged
- Core VM behavior identical
- All instructions preserve semantics

---

## License Changes

### Version 2.0.0
- **Primary:** MIT License (permissive, widely compatible)
- **Secondary:** Palimpsest License v0.8 (audit-grade, consent-aware)
- **Legacy:** AGPL-3.0 (available in license.txt for compatibility)

Users may choose either MIT or Palimpsest for their use.

### Version 1.0.0
- **License:** AGPL-3.0 only

---

[Unreleased]: https://github.com/yourusername/idaptik-reversible/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/yourusername/idaptik-reversible/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/yourusername/idaptik-reversible/releases/tag/v1.0.0
