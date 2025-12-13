# Tri-Perimeter Contribution Framework (TPCF)

## Perimeter Designation

**Idaptik Reversible VM** operates under:

## **Perimeter 3: Community Sandbox** 🌍

### What This Means

This project is **fully open to public contribution** with the following characteristics:

- ✅ **Open Contribution**: Anyone can propose changes
- ✅ **Public Discussion**: All decisions made transparently
- ✅ **Collaborative Governance**: Community input valued
- ✅ **Fork-Friendly**: Feel free to fork and experiment
- ✅ **Beginner-Friendly**: We welcome first-time contributors

### Contribution Model

```
┌─────────────────────────────────────────────┐
│         PERIMETER 3: Community Sandbox       │
│                                              │
│  Anyone → Propose → Discuss → Review → Merge│
│                                              │
│  • No pre-approval needed                   │
│  • Open issue/PR system                     │
│  • Maintainer review required               │
│  • Community can participate in review      │
└─────────────────────────────────────────────┘
```

## TPCF Overview

The Tri-Perimeter Contribution Framework defines three trust levels for open source contribution:

### Perimeter 1: Core (Not Used Here)

- **Who**: 1-3 core maintainers only
- **Access**: Direct commit rights
- **Use Case**: Critical infrastructure, security-sensitive code
- **Example**: Cryptographic implementations, auth systems

### Perimeter 2: Trusted (Not Used Here)

- **Who**: Vetted contributors with proven track record
- **Access**: Fast-track review, higher trust
- **Use Case**: Production systems with some stability needs
- **Example**: Production web apps, libraries with many dependents

### Perimeter 3: Community Sandbox (Our Choice) ✅

- **Who**: Anyone with a GitHub account
- **Access**: Standard fork/PR workflow
- **Use Case**: Educational projects, experimental code, community-driven tools
- **Example**: This project! Learning-focused, experimental, welcoming

## Why Perimeter 3 for Idaptik?

This project is **educational and experimental** by nature:

1. **Learning Tool**: Designed to teach reversible computing concepts
2. **Safe to Experiment**: ReScript's type system catches many errors at compile time
3. **Comprehensive Tests**: Reversibility guarantees are testable
4. **No Production Critical**: Not deployed in high-stakes environments
5. **Community Growth**: We want to encourage contribution and learning

### Safety Mechanisms

Even as Perimeter 3, we maintain quality through:

- ✅ **Type Safety**: ReScript prevents entire classes of bugs
- ✅ **Test Suite**: All changes must pass tests
- ✅ **Reversibility Tests**: Core principle mechanically verified
- ✅ **Code Review**: Maintainers review all merges
- ✅ **CI/CD Pipeline**: Automated verification before merge
- ✅ **Clear Guidelines**: CONTRIBUTING.md provides structure

## Contribution Workflow

### 1. Anyone Can Contribute

```bash
# Fork the repo
gh repo fork Hyperpolymath/idaptiky

# Make changes
git checkout -b my-feature
# ... make changes ...
just build && just test

# Submit PR
gh pr create --title "Add awesome feature"
```

### 2. Community Review

- Maintainers review (see [MAINTAINERS.md](MAINTAINERS.md))
- Community can comment and suggest
- CI/CD runs automated checks
- Discussion happens publicly

### 3. Merge or Iterate

- **Approved**: Merged by maintainer
- **Changes Needed**: Contributor iterates based on feedback
- **Declined**: Clearly explained with reasoning

## Permissions and Access

### What You CAN Do (No Permission Needed)

- ✅ Fork the repository
- ✅ Open issues (bugs, features, questions)
- ✅ Submit pull requests
- ✅ Comment on existing issues/PRs
- ✅ Participate in discussions
- ✅ Use the code under MIT or Palimpsest license
- ✅ Create your own fork with changes

### What Requires Review

- ⏸️ Merging to main branch (maintainer only)
- ⏸️ Creating releases (maintainer only)
- ⏸️ Modifying CI/CD (maintainer review required)
- ⏸️ Changing security policies (maintainer review required)

### What's Restricted

- ❌ Direct commits to main (use PRs instead)
- ❌ Deleting branches (except your own forks)
- ❌ Modifying protected settings (maintainer only)
- ❌ Publishing releases (maintainer only)

## Good First Issues

We mark issues suitable for beginners with `good first issue` label:

- 🟢 **Documentation**: Improve README, add examples
- 🟢 **Testing**: Add test cases, improve coverage
- 🟢 **New Instructions**: Implement new reversible operations
- 🟢 **Puzzle Creation**: Design new puzzle challenges (when implemented)
- 🟢 **Bug Fixes**: Fix identified issues

## Trust Escalation

Contributors can gain trust over time:

### Recognition Path

1. **First Contribution**: Listed in git history
2. **Regular Contributor**: Mentioned in CHANGELOG.md
3. **Significant Contribution**: Thanked in humans.txt
4. **Consistent Quality**: Potential maintainer nomination

See [MAINTAINERS.md](MAINTAINERS.md) for becoming a maintainer.

## Perimeter Transition

If project needs change, we may transition perimeters:

### To Perimeter 2 (Trusted)

If the project becomes production-critical:
- Notify community 30 days in advance
- Clearly document new requirements
- Grandfather existing trusted contributors
- Update this file

### To Perimeter 1 (Core)

If security becomes critical (unlikely for this project):
- Notify community 60 days in advance
- Explain reasoning transparently
- Offer alternatives (forks, etc.)
- Update this file

**Note**: We have no plans to change from Perimeter 3. This is the right model for Idaptik.

## Questions

### "Can I fork this and make my own version?"

**Yes!** That's exactly what Perimeter 3 encourages. Both MIT and Palimpsest licenses permit this.

### "Do I need permission to contribute?"

**No!** Just follow [CONTRIBUTING.md](CONTRIBUTING.md) and submit a PR.

### "What if my PR is rejected?"

We'll explain why clearly. You can:
- Revise and resubmit
- Maintain it in your fork
- Open a discussion to understand better

### "Can I become a maintainer?"

Yes! See [MAINTAINERS.md](MAINTAINERS.md) for the path.

### "What if I break something?"

Don't worry! That's what tests and review are for. We:
- Catch issues in CI/CD
- Review before merging
- Can revert if needed (reversibility! 😄)

## Comparison to Other Projects

### Similar to Idaptik (Perimeter 3)

- Educational repos
- Experimental frameworks
- Community-driven tools
- Example projects
- Learning resources

### Different from Idaptik (Perimeter 1/2)

- Production databases
- Security libraries
- Operating system components
- Financial software
- Medical device code

## Resources

### Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards
- [MAINTAINERS.md](MAINTAINERS.md) - Who maintains what
- [SECURITY.md](SECURITY.md) - Security policies

### External Resources

- [TPCF Specification](https://rhodium.dev/tpcf) (conceptual)
- [Contributor Covenant](https://www.contributor-covenant.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

## Version History

- **v1.0.0** (2025-11-22): Initial TPCF designation (Perimeter 3)

---

**Current Status**: ✅ Perimeter 3: Community Sandbox

**Last Updated**: 2025-11-22

**Questions?** Open a GitHub discussion or see [CONTRIBUTING.md](CONTRIBUTING.md).

---

**Welcome to Perimeter 3! We're excited to collaborate with you!** 🎉
