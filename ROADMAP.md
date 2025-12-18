# IDApTIK Roadmap

**Last Updated**: 2025-12-17
**Status**: Active Development

---

## Project Overview

IDApTIK is a multi-component project consisting of:
- **IDApTIK Core**: Asymmetric multiplayer camera system (Rust + Elixir)
- **Reversible VM**: Educational reversible computing platform (ReScript + Deno)

---

## Current State (Q4 2025)

### Completed
- [x] SHA-pinned GitHub Actions (all workflows)
- [x] SPDX license headers on all workflows
- [x] CodeQL security scanning
- [x] OSSF Scorecard integration
- [x] Dependabot configuration (actions, cargo, npm, pip)
- [x] TruffleHog secret scanning
- [x] Workflow security linter
- [x] RFC 9116 compliant security.txt
- [x] SECURITY.md vulnerability disclosure policy
- [x] ReScript policy enforcement (ts-blocker)
- [x] Container policy enforcement (nerdctl/podman)
- [x] RSR Bronze Tier compliance

### VM Component (v2.0.0)
- [x] Core VM with 5 reversible instructions
- [x] ReScript type-safe implementation
- [x] Deno runtime (zero dependencies)
- [x] Just build system
- [x] CLI interface

### Core Component
- [x] Asymmetric camera architecture design
- [x] Elixir Port communication protocol
- [x] Rust/Bevy rendering setup

---

## Roadmap

### Phase 1: Foundation (Q1 2026)

#### Security & Compliance
- [ ] Add branch protection rules
- [ ] Enable required reviews for PRs
- [ ] Configure CODEOWNERS file
- [ ] Add signed commits enforcement
- [ ] Implement security scanning for Rust (cargo-audit)

#### VM Development
- [ ] Puzzle loader implementation
- [ ] Binary/bitwise operations (XOR, ROL, ROR)
- [ ] Test framework setup
- [ ] Property-based testing (reversibility)

#### Core Development
- [ ] Rust core standalone testing
- [ ] Elixir Port supervisor implementation
- [ ] Basic entity system

### Phase 2: Feature Development (Q2-Q3 2026)

#### VM Enhancements
- [ ] 20+ starter puzzles
- [ ] Puzzle validation system
- [ ] Performance benchmarks
- [ ] Documentation expansion

#### Core Game Features
- [ ] Hacker view (top-down camera)
- [ ] Infiltrator view (side-scroll camera)
- [ ] Rapier physics integration
- [ ] Guard AI patrol system

### Phase 3: User Experience (Q4 2026)

#### Web Interface
- [ ] Deno Fresh application
- [ ] Interactive playground
- [ ] Puzzle browser/solver
- [ ] Visual debugger

#### Multiplayer
- [ ] QUIC networking (CURP)
- [ ] FlatBuffers serialization
- [ ] Voice chat integration
- [ ] Matchmaking system

### Phase 4: Ecosystem (2027)

#### Language & Tools
- [ ] Reversible assembly language (IdAsm)
- [ ] High-level language (IdaLang)
- [ ] VS Code extension
- [ ] Language bindings (JS, Python, Rust)

#### Research
- [ ] Formal verification (TLA+)
- [ ] Quantum circuit bridge
- [ ] Academic papers

### Phase 5: Production (2028+)

#### Advanced Features
- [ ] Distributed reversible computing
- [ ] FPGA implementation
- [ ] Machine learning integration
- [ ] RSR Gold Tier compliance

---

## Security Roadmap

### Immediate (Done)
- [x] SHA-pin all GitHub Actions
- [x] Add CodeQL scanning
- [x] Add OSSF Scorecard
- [x] Add secret scanning
- [x] Fix security.txt expiry date
- [x] Add root SECURITY.md

### Short-term (Q1 2026)
- [ ] Add CODEOWNERS
- [ ] Enable branch protection
- [ ] Add security policy for Rust deps
- [ ] Implement SBOM generation

### Medium-term (Q2-Q4 2026)
- [ ] Third-party security audit
- [ ] Bug bounty program
- [ ] Security certifications

---

## Policy Compliance

### RSR (Rhodium Standard Repository)
| Tier | Status | Requirements |
|------|--------|--------------|
| Bronze | :white_check_mark: | Basic docs, CI, security |
| Silver | Planned Q3 2026 | 90% coverage, benchmarks, i18n |
| Gold | Planned 2027 | Formal verification, audit |
| Platinum | Aspirational | Industry standard adoption |

### Container Policy
- Runtime: nerdctl (primary) / podman (fallback)
- Base Image: wolfi (primary) / alpine (fallback)
- Format: Containerfile (not Dockerfile)

### Language Policy
- New code: ReScript only
- Existing TS/JS: Migration in progress
- Generated files: .res.js allowed

---

## Contributing

See [CONTRIBUTING.md](vm/CONTRIBUTING.md) for contribution guidelines.

### Priority Areas
1. VM puzzle creation
2. Documentation improvements
3. Test coverage expansion
4. Web interface development

---

## Success Metrics (2030 Vision)

| Category | Target |
|----------|--------|
| GitHub Stars | 10,000+ |
| Contributors | 100+ |
| University Courses | 20+ |
| Academic Citations | 50+ |
| Test Coverage | >95% |

---

*This roadmap is a living document. Contributions welcome via GitHub discussions.*
