# Security Policy

## Supported Versions

We take security seriously for the Idaptik Reversible VM project. Currently supported versions:

| Version | Supported          | Notes |
| ------- | ------------------ | ----- |
| 2.0.x   | :white_check_mark: | Current ReScript/Deno implementation |
| 1.0.x   | :x:                | Legacy TypeScript version (deprecated) |

## Security Model

### Design Philosophy

Idaptik is designed with security in mind through several architectural choices:

1. **Type Safety**: ReScript's sound type system eliminates entire classes of vulnerabilities
   - No null pointer exceptions
   - No type coercion bugs
   - Compile-time guarantees prevent runtime type errors

2. **Memory Safety**: Automatic memory management
   - No buffer overflows
   - No use-after-free vulnerabilities
   - Garbage collection handles all memory

3. **Offline-First**: Zero network calls
   - No remote code execution risks
   - Works completely air-gapped
   - No dependency on external services

4. **Zero Runtime Dependencies**: Minimal attack surface
   - No npm packages in production
   - Only Deno runtime + compiled ReScript
   - Explicit permissions model (Deno `--allow-*`)

5. **Sandboxed Execution**: Deno permission system
   - File access requires `--allow-read`
   - Network access requires `--allow-net` (not used)
   - Explicit permissions prevent unauthorized access

### Threat Model

**In Scope:**
- Type confusion vulnerabilities (mitigated by ReScript)
- State manipulation bugs (tested via reversibility guarantees)
- Input validation issues (ReScript types enforce contracts)
- Build process integrity

**Out of Scope:**
- Network-based attacks (no network code)
- SQL injection (no database)
- XSS/CSRF (no web interface in core VM)
- Buffer overflows (automatic memory management)

## Reporting a Vulnerability

### How to Report

If you discover a security vulnerability, please report it via:

1. **GitHub Security Advisories** (preferred):
   - Go to https://github.com/Hyperpolymath/idaptiky/security/advisories/new
   - Click "Report a vulnerability"
   - Fill in the details

2. **Email** (for sensitive issues):
   - Send to: security@idaptiky.dev
   - Use PGP if available (key on request)
   - Include "SECURITY" in subject line

### What to Include

Please provide:

- **Description**: Clear description of the vulnerability
- **Impact**: What can an attacker do?
- **Reproduction**: Step-by-step instructions to reproduce
- **Version**: Which version(s) are affected?
- **Fix Suggestion**: (Optional) How to fix it

Example:
```markdown
## Vulnerability: State Corruption via Invalid Instruction

**Impact**: Attacker can corrupt VM state by providing malformed instruction

**Reproduction**:
1. Create instruction with null variable name
2. Execute via VM.run()
3. State becomes inconsistent

**Affected Versions**: 2.0.0

**Fix**: Add null checks in instruction constructors
```

### Response Timeline

We aim to respond to security reports according to this timeline:

| Timeframe | Action |
|-----------|--------|
| 24 hours  | Acknowledge receipt |
| 72 hours  | Initial assessment and severity rating |
| 7 days    | Fix developed (for critical issues) |
| 14 days   | Fix released and CVE assigned (if applicable) |
| 30 days   | Public disclosure (coordinated with reporter) |

**Severity Ratings:**

- **Critical**: Remote code execution, privilege escalation
- **High**: Data corruption, authentication bypass
- **Medium**: Information disclosure, DoS
- **Low**: Edge cases, theoretical issues

### Disclosure Policy

We follow **coordinated disclosure**:

1. Reporter submits vulnerability privately
2. We develop and test a fix
3. We release patched version
4. We publish security advisory
5. Reporter receives credit (unless anonymous requested)

**Embargo Period**: 90 days maximum (negotiable for complex issues)

## Security Best Practices

### For Users

When using Idaptik:

1. **Use Latest Version**: Always use the most recent 2.0.x release
2. **Verify Checksums**: Verify download integrity
3. **Review Permissions**: Understand what `--allow-*` flags grant
4. **Audit Puzzles**: Review JSON puzzle files before loading (when implemented)
5. **Sandboxed Testing**: Test unknown code in isolated environments

### For Developers

When contributing:

1. **Type Safety**: Use ReScript's type system fully
   - Never use `Js.Unsafe.*` functions
   - Avoid `external` declarations without validation
   - Let the compiler catch bugs

2. **Input Validation**: Validate all external input
   - Puzzle JSON files (when loader implemented)
   - Command-line arguments
   - User-provided state values

3. **Reversibility Testing**: Test all code paths
   - Every instruction must have perfect inverse
   - Test `execute(invert(state)) === state`
   - No information loss allowed

4. **Dependencies**: Keep zero runtime dependencies
   - No npm packages in production
   - Build-time dependencies carefully vetted
   - Minimize attack surface

5. **Code Review**: All changes reviewed
   - Security implications considered
   - Test coverage required
   - Reversibility guarantees maintained

## Security Features by Component

### Core VM (`src/core/VM.res`)

- **State Isolation**: Each VM instance has isolated state
- **History Integrity**: Execution history immutable once recorded
- **Type Safety**: All operations type-checked at compile time

### Instructions (`src/core/instructions/*.res`)

- **Bounded Operations**: No unbounded loops or recursion
- **Deterministic**: Same input always produces same output
- **Reversible**: Every operation perfectly invertible

### CLI (`src/CLI.res`)

- **Argument Validation**: All CLI args validated
- **File Access**: Only reads files with explicit permission
- **No Remote Access**: Zero network calls

### Build System (`justfile`)

- **Reproducible Builds**: Deterministic compilation
- **Dependency Locking**: ReScript version pinned
- **Integrity Checks**: Build verification tests

## Vulnerability History

### 2.0.x Series

No vulnerabilities reported to date.

### 1.0.x Series (Deprecated)

The legacy TypeScript version is no longer supported. Users should migrate to 2.0.x.

## Security Tools

### Static Analysis

```bash
# ReScript type checking (built-in)
just build

# Code quality
just lint

# Full verification
just verify
```

### Testing

```bash
# Run all tests (including reversibility)
just test

# CI pipeline (comprehensive)
just ci
```

### Dependency Auditing

```bash
# Check build dependencies (npm for ReScript compiler only)
npm audit

# Check Deno cache
deno info
```

## Compliance

This project follows:

- **Rhodium Standard Repository (RSR)**: Full compliance
- **RFC 9116**: security.txt standard
- **Palimpsest License v0.8**: Ethical use guidelines
- **OWASP Top 10**: Mitigations for common vulnerabilities

## Security Contact

- **Primary**: https://github.com/Hyperpolymath/idaptiky/security
- **Email**: security@idaptiky.dev
- **Policy**: See `.well-known/security.txt`

## Acknowledgments

We thank the following individuals for responsibly disclosing security issues:

(No reports yet - this section will be updated as needed)

---

**Last Updated**: 2025-11-22
**Version**: 2.0.0
**Canonical URL**: https://github.com/Hyperpolymath/idaptiky/blob/main/SECURITY.md

For general questions, see [CONTRIBUTING.md](CONTRIBUTING.md).
