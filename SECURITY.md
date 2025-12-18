# Security Policy

## Supported Versions

| Version | Supported          | Notes |
| ------- | ------------------ | ----- |
| 2.x     | :white_check_mark: | Current ReScript implementation |
| 1.x     | :x:                | Legacy TypeScript (deprecated) |

## Security Model

### Design Principles

1. **Type Safety**: ReScript's sound type system eliminates entire vulnerability classes
2. **Memory Safety**: Automatic memory management (no buffer overflows)
3. **Minimal Attack Surface**: Zero runtime npm dependencies
4. **Sandboxed Execution**: Deno permission model for explicit resource access
5. **SHA-Pinned Dependencies**: All GitHub Actions pinned to commit SHAs

### CI/CD Security

This repository enforces:
- SHA-pinned GitHub Actions (verified by `workflow-linter.yml`)
- SPDX license headers on all workflows
- Least-privilege permissions (`read-all` default)
- Secret scanning via TruffleHog
- OSSF Scorecard analysis
- CodeQL static analysis
- Dependabot automated updates

## Reporting a Vulnerability

### Preferred Method

1. **GitHub Security Advisories** (recommended):
   - Go to https://github.com/hyperpolymath/idaptik/security/advisories/new
   - Click "Report a vulnerability"
   - Provide detailed information

2. **Email** (for sensitive issues):
   - Send to: security@hyperpolymath.org
   - Include "SECURITY" in subject line

### What to Include

- **Description**: Clear explanation of the vulnerability
- **Impact**: What can an attacker achieve?
- **Reproduction**: Step-by-step instructions
- **Version**: Affected version(s)
- **Fix Suggestion**: (Optional) Proposed solution

### Response Timeline

| Timeframe | Action |
|-----------|--------|
| 24 hours  | Acknowledge receipt |
| 72 hours  | Initial assessment |
| 7 days    | Fix developed (critical) |
| 14 days   | Fix released |
| 30 days   | Public disclosure (coordinated) |

## Security Best Practices

### For Contributors

1. **Never commit secrets** - Use environment variables
2. **Use ReScript** - Leverage type safety
3. **SHA-pin actions** - No version tags in workflows
4. **Least privilege** - Minimal permissions for jobs
5. **Review dependencies** - Audit before adding

### For Users

1. **Use latest version** - Stay on supported releases
2. **Verify checksums** - Validate downloads
3. **Review permissions** - Understand `--allow-*` flags
4. **Audit puzzles** - Review untrusted JSON files

## Compliance

- **RFC 9116**: security.txt standard (see `.well-known/security.txt`)
- **OSSF Best Practices**: Scorecard integration
- **RSR (Rhodium Standard Repository)**: Full compliance

## Security Contact

- **Primary**: https://github.com/hyperpolymath/idaptik/security
- **Email**: security@hyperpolymath.org
- **Policy**: `.well-known/security.txt`

## Acknowledgments

We thank security researchers who responsibly disclose issues.

(No reports to date)

---

**Last Updated**: 2025-12-17
**Canonical URL**: https://github.com/hyperpolymath/idaptik/blob/main/SECURITY.md
