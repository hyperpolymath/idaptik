# Maintainers

This file lists the current maintainers of the Idaptik Reversible VM project and defines their roles and responsibilities.

## Current Maintainers

### Lead Maintainers

**Joshua & Jonathan Jewell** (@Hyperpolymath)
- **Role**: Original Authors, Lead Maintainers
- **Responsibilities**:
  - Overall project direction and vision
  - Architecture decisions
  - Release management
  - Security response
  - Final review authority
- **Focus Areas**: Core VM, ReScript implementation, reversibility theory
- **Contact**: Via GitHub (@Hyperpolymath)
- **Timezone**: Earth Standard Time
- **Since**: 2024 (v1.0.0), 2025-11-21 (v2.0.0 rewrite)

## Maintainer Responsibilities

### General Duties

All maintainers are expected to:

1. **Code Review**
   - Review pull requests in their area of expertise
   - Provide constructive, timely feedback
   - Ensure code meets quality standards
   - Test changes when appropriate

2. **Issue Triage**
   - Label and categorize new issues
   - Ask for clarification when needed
   - Close duplicates or resolved issues
   - Identify good first issues for newcomers

3. **Community Engagement**
   - Answer questions in discussions
   - Welcome new contributors
   - Model Code of Conduct behavior
   - Foster inclusive environment

4. **Documentation**
   - Keep documentation up to date
   - Write clear commit messages
   - Update CHANGELOG.md for releases
   - Improve guides based on questions

5. **Quality Assurance**
   - Maintain test coverage
   - Run full test suite before merging
   - Verify reversibility guarantees
   - Check RSR compliance

### Specific Responsibilities

#### Core VM Maintainers

Responsible for:
- `src/core/` directory
- Virtual machine implementation
- State management
- Instruction interface
- Reversibility guarantees
- Performance optimization

**Current**: Joshua & Jonathan Jewell

#### Instruction Set Maintainers

Responsible for:
- `src/core/instructions/` directory
- Individual instruction implementations
- Inverse operation correctness
- New instruction proposals
- Instruction testing

**Current**: Joshua & Jonathan Jewell

#### Build System Maintainers

Responsible for:
- `justfile` recipes
- ReScript configuration
- Deno configuration
- CI/CD pipeline (`.gitlab-ci.yml`)
- Release automation

**Current**: Joshua & Jonathan Jewell

#### Documentation Maintainers

Responsible for:
- README.md
- MIGRATION-GUIDE.md
- CONTRIBUTING.md
- This file (MAINTAINERS.md)
- API documentation
- Tutorial content

**Current**: Joshua & Jonathan Jewell

#### Security Maintainers

Responsible for:
- SECURITY.md
- Security advisories
- Vulnerability response
- `.well-known/security.txt`
- Dependency audits
- Security best practices

**Current**: Joshua & Jonathan Jewell

## Becoming a Maintainer

### Paths to Maintainership

We welcome new maintainers! Here's how to get there:

1. **Contribute Consistently**
   - Make high-quality contributions over time
   - Show understanding of project goals
   - Help others in discussions
   - Review others' PRs (even without merge rights)

2. **Demonstrate Expertise**
   - Deep knowledge of specific project area
   - Understand reversibility principles
   - Grasp ReScript type system
   - Know project architecture

3. **Show Reliability**
   - Respond to feedback promptly
   - Follow through on commitments
   - Communicate when unavailable
   - Respect deadlines

4. **Embody Values**
   - Follow Code of Conduct
   - Support other contributors
   - Prioritize project health
   - Make thoughtful decisions

### Nomination Process

1. **Nomination**: Current maintainer nominates candidate
2. **Discussion**: Maintainers discuss privately (1 week)
3. **Consensus**: All current maintainers must approve
4. **Invitation**: Lead maintainers extend invitation
5. **Onboarding**: New maintainer receives:
   - Repository write access
   - Introduction to team
   - Area of responsibility
   - Mentorship from existing maintainer

### Trial Period

New maintainers undergo a 90-day trial period:

- **Month 1**: Shadowing (learn by observing)
- **Month 2**: Assisted (make decisions with guidance)
- **Month 3**: Independent (make decisions with review)

After 90 days:
- **Success**: Full maintainer status
- **Extension**: Another 30-90 days if needed
- **Decline**: Revert to contributor (no shame in this!)

## Maintainer Expectations

### Time Commitment

- **Minimum**: 2-4 hours per week
- **Flexible**: Life happens, communicate your availability
- **Sustainable**: Quality over quantity
- **Breaks**: Take time off, hand off responsibilities

### Decision-Making

Maintainers make decisions using:

1. **Lazy Consensus**: Assumed yes unless objections
   - Post proposal with 72-hour feedback period
   - No objections = approved
   - Used for: minor changes, documentation, refactoring

2. **Consensus Seeking**: Discussion to agreement
   - Discuss until all concerns addressed
   - May take multiple iterations
   - Used for: new features, architecture changes

3. **Voting**: Last resort for deadlocks
   - Simple majority wins
   - Lead maintainers break ties
   - Used for: major disagreements (rare)

### Communication

Maintainers should:

- **Be Responsive**: Reply within 7 days (ideally 2-3)
- **Be Transparent**: Explain decisions publicly
- **Be Respectful**: Follow Code of Conduct rigorously
- **Be Available**: Post vacation/busy periods in advance

## Stepping Down

Maintainers can step down at any time:

1. **Notify** other maintainers (private or public)
2. **Transfer** responsibilities to someone else
3. **Document** in-progress work and context
4. **Update** this file to reflect change
5. **Keep** contributor access if desired

**No shame in stepping down!** Life changes, interests change, burnout happens. We're grateful for all contributions.

### Emeritus Status

Former maintainers who stepped down honorably receive:

- **Title**: "Maintainer Emeritus" in humans.txt
- **Credit**: Listed in acknowledgments
- **Respect**: Continued welcome in community
- **Voice**: Input valued (but not binding)

## Inactive Maintainers

If a maintainer is inactive (no response for 60+ days):

1. **Reach out**: Try to contact via all known channels
2. **Wait**: Allow 30 days for response
3. **Temporarily reassign**: Move responsibilities to others
4. **Update status**: Mark as inactive in this file
5. **Restore**: Full restoration when they return

## Conflict Resolution

### Between Maintainers

1. **Direct discussion**: Talk it out privately first
2. **Mediation**: Another maintainer mediates
3. **Lead decision**: Lead maintainers make final call
4. **Escalation**: (Rare) May require stepping down

### With Contributors

1. **Assume good faith**: Misunderstandings are common
2. **Clarify**: Ask questions before judging
3. **Code of Conduct**: Follow enforcement process
4. **Learn**: Update docs if pattern emerges

## Maintainer Resources

### Tools and Access

Maintainers have access to:

- Repository write permissions
- CI/CD pipeline access
- Release creation rights
- Security advisory access
- Discussion moderation tools

### Communication Channels

- **Public**: GitHub issues and discussions
- **Private**: (To be established as team grows)
- **Security**: security@idaptiky.dev
- **Conduct**: conduct@idaptiky.dev

### Documentation

Essential reading for maintainers:

- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution workflow
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards
- [SECURITY.md](SECURITY.md) - Security policies
- [RSR-COMPLIANCE.md](RSR-COMPLIANCE.md) - RSR standards
- [justfile](justfile) - All build commands

## Gratitude

### Current Team

Thank you to all current maintainers for your time, expertise, and dedication!

### Past Contributors

We're grateful to everyone who has contributed, even if not currently maintaining. Your work matters!

### Community

Thank you to our users, bug reporters, documentation improvers, and question-askers. You make this project better!

## Contact

- **Maintainer Questions**: Open a GitHub discussion
- **Private Matters**: Contact lead maintainers via GitHub
- **Security**: See [SECURITY.md](SECURITY.md)
- **Conduct**: See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

---

**Last Updated**: 2025-11-22
**Version**: 1.0.0

This file is maintained by the lead maintainers and updated as the team changes.

See also:
- [humans.txt](.well-known/humans.txt) - Human-readable project info
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards
