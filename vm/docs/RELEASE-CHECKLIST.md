# Release Checklist

**Complete checklist for Idaptik releases**

## Pre-Release (1-2 weeks before)

### Code Freeze

- [ ] Feature freeze announced (no new features)
- [ ] Only bug fixes allowed
- [ ] Update CHANGELOG.md with all changes
- [ ] Review all open PRs
- [ ] Merge or defer remaining PRs

### Testing

- [ ] All tests passing (`just test`)
- [ ] All examples running (`just examples`)
- [ ] All benchmarks stable (`just benchmark`)
- [ ] RSR verification passing (`just rsr-verify`)
- [ ] Full CI pipeline green (`just ci`)
- [ ] Manual testing on 3+ platforms (Linux, macOS, Windows)

### Documentation

- [ ] README.md updated
- [ ] API-REFERENCE.md current
- [ ] Tutorials tested
- [ ] CHANGELOG.md complete
- [ ] Migration guide (if breaking changes)
- [ ] Known issues documented

### Version Bump

- [ ] Decide version number (major.minor.patch)
- [ ] Update `rescript.json` version
- [ ] Update `package.json` version
- [ ] Update version in README badges
- [ ] Update copyright years if needed

---

## Release Day

### Final Verification

- [ ] `just clean-all`
- [ ] `just build`
- [ ] `just verify`
- [ ] `just ci`
- [ ] `just rsr-verify`
- [ ] All checks passing ✅

### Git Operations

- [ ] Commit version bump:
  ```bash
  git add rescript.json package.json CHANGELOG.md
  git commit -m "chore: bump version to vX.Y.Z"
  ```

- [ ] Tag release:
  ```bash
  git tag -a vX.Y.Z -m "Release vX.Y.Z"
  ```

- [ ] Push to GitHub:
  ```bash
  git push origin main
  git push origin vX.Y.Z
  ```

### GitHub Release

- [ ] Create release on GitHub:
  ```bash
  gh release create vX.Y.Z \
    --title "vX.Y.Z - Release Name" \
    --notes-file RELEASE_NOTES.md
  ```

- [ ] Attach artifacts (if any):
  - Source code (auto-generated)
  - Compiled binaries (future)
  - Documentation PDF (future)

- [ ] Mark as latest release

### Publish (Future)

When package is published to registries:

- [ ] npm: `npm publish`
- [ ] PyPI: `python -m twine upload dist/*`
- [ ] crates.io: `cargo publish`
- [ ] WASM: Deploy to CDN

---

## Post-Release

### Announcements

- [ ] Tweet from @IdaptikVM
- [ ] Post to r/reversiblecomputing
- [ ] Discord announcement
- [ ] Update website (when exists)
- [ ] Email to mailing list (when exists)

### Documentation

- [ ] Update online docs
- [ ] Regenerate API docs
- [ ] Update examples to use new version
- [ ] Blog post (for major releases)

### Community

- [ ] Thank contributors in release notes
- [ ] Close resolved issues
- [ ] Update project board
- [ ] Review and triage new issues

### Preparation for Next Release

- [ ] Create vX.Y.(Z+1) milestone
- [ ] Move deferred items to next milestone
- [ ] Plan next release features
- [ ] Update GRAND-VISION-MAP.md progress

---

## Release Types

### Patch Release (vX.Y.Z → vX.Y.Z+1)

**When:** Bug fixes only
**Frequency:** As needed
**Timeline:** 1 week

**Checklist:**
- [ ] Bug fixes only
- [ ] No new features
- [ ] No breaking changes
- [ ] Minimal documentation changes

### Minor Release (vX.Y.Z → vX.Y+1.0)

**When:** New features, backwards compatible
**Frequency:** Monthly or quarterly
**Timeline:** 2-4 weeks

**Checklist:**
- [ ] New features
- [ ] Backwards compatible
- [ ] Update tutorials
- [ ] New examples (if appropriate)

### Major Release (vX.Y.Z → vX+1.0.0)

**When:** Breaking changes
**Frequency:** Yearly or longer
**Timeline:** 2-3 months

**Checklist:**
- [ ] Breaking changes documented
- [ ] Migration guide written
- [ ] Community notified 1 month in advance
- [ ] Deprecation warnings in previous release
- [ ] Major announcement campaign

---

## Emergency Hotfix

**For critical security or data-loss bugs**

### Immediate Actions

1. [ ] Create hotfix branch:
   ```bash
   git checkout -b hotfix/vX.Y.Z+1 vX.Y.Z
   ```

2. [ ] Fix bug with minimal changes

3. [ ] Test thoroughly

4. [ ] Bump patch version

5. [ ] Merge to main:
   ```bash
   git checkout main
   git merge hotfix/vX.Y.Z+1
   ```

6. [ ] Release immediately (skip pre-release)

7. [ ] Announce with severity level

---

## Version Examples

### v2.0.0 → v2.0.1 (Patch)
- Fixed XOR instruction bug
- Updated documentation typos
- No new features

### v2.0.0 → v2.1.0 (Minor)
- Added ROL/ROR instructions
- 20+ new puzzles
- Benchmark infrastructure
- Backwards compatible

### v2.0.0 → v3.0.0 (Major)
- Rewrote VM in Rust (breaking)
- New puzzle JSON format
- Migration guide provided
- 3-month deprecation period

---

## Quality Gates

### Must Pass

All of these must be true before release:

- ✅ `just ci` passes
- ✅ `just rsr-verify` 100%
- ✅ No known critical bugs
- ✅ All documentation updated
- ✅ CHANGELOG.md complete
- ✅ At least 1 week of testing

### Nice to Have

These are goals but not blockers:

- ⭐ All "good first issue" resolved
- ⭐ Test coverage >90%
- ⭐ Performance benchmarks improved
- ⭐ Community feedback addressed

---

## Rollback Plan

If release has critical issues:

1. [ ] **Yank release** (if published to registries)

2. [ ] **Tag previous version** as latest:
   ```bash
   gh release edit vX.Y.Z-1 --latest
   ```

3. [ ] **Announce rollback**

4. [ ] **Fix issues**

5. [ ] **Re-release** as vX.Y.Z+1

---

## Communication Templates

### Pre-Release Announcement

```markdown
🎉 Idaptik vX.Y.Z coming soon!

Release Date: YYYY-MM-DD
Highlights:
- Feature 1
- Feature 2
- Feature 3

See full changelog: [link]

Help us test: [link to RC]
```

### Release Announcement

```markdown
🚀 Idaptik vX.Y.Z released!

What's New:
- Feature 1
- Feature 2
- Fix 1

Upgrade:
`npm install -g idaptik@X.Y.Z`

Docs: [link]
Changelog: [link]

Thanks to [contributors]!
```

### Hotfix Announcement

```markdown
🚨 Security Hotfix: Idaptik vX.Y.Z

Severity: High
Issue: [description]
Fix: [description]

Please upgrade immediately:
`npm install -g idaptik@X.Y.Z`

Details: [link]
```

---

## Metrics to Track

- **Downloads**: npm, PyPI, crates.io
- **Stars**: GitHub stars
- **Contributors**: Unique committers
- **Issues**: Open vs closed
- **Community**: Discord members, forum posts
- **Performance**: Benchmark trends

---

## Post-Mortem (After Major Releases)

Within 1 week after release:

- [ ] What went well?
- [ ] What went wrong?
- [ ] What should we change?
- [ ] Update this checklist based on learnings

---

**Use this checklist for every release!**

Track completion: `docs/releases/vX.Y.Z-checklist.md`
