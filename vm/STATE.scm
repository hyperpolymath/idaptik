;;; STATE.scm — Conversation checkpoint for idaptiky project
;;; Format: Guile Scheme s-expressions
;;; CRITICAL: Download this file at end of each session!
;;;           At start of next conversation, upload it.

(define state
  '((metadata
     (format-version . "1.0.0")
     (created . "2025-12-08")
     (updated . "2025-12-08")
     (generator . "claude-opus-4"))

    (user-context
     (name . "hyperpolymath")
     (roles . ("maintainer" "architect"))
     (languages . ("ReScript" "TypeScript" "Scheme" "Deno"))
     (tools . ("just" "deno" "git" "rescript"))
     (values . ("reversible-computing" "educational" "zero-dependencies" "type-safety")))

    (session-context
     (conversation-id . "create-state-scm-017eWBa22w17Ybidrm3kq9TX")
     (message-count . 1)
     (token-limit-warning . #f))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; CURRENT POSITION
    ;;; ═══════════════════════════════════════════════════════════════════

    (focus
     (project . "idaptiky")
     (phase . "MVP-completion")
     (deadline . #f)
     (blocking . ("interactive-cli-mode")))

    (current-position
     (summary . "Reversible VM v2.0.0 released with complete core engine, 13 instructions, and 26 puzzles. CLI demo/test working but interactive puzzle-solving mode not implemented.")
     (version . "2.0.0")
     (release-date . "2025-11-21")
     (rsr-compliance . "bronze")
     (license . "MIT OR Palimpsest-0.8")

     (completed-features
      ("Core VM with instruction execution/inversion")
      ("13 reversible instructions (ADD SUB MUL DIV XOR AND OR FLIP ROL ROR SWAP NEGATE NOOP)")
      ("State management (create clone serialize deserialize match)")
      ("History tracking for undo/redo")
      ("CLI interface with demo test help commands")
      ("26 puzzle JSON definitions (beginner to expert)")
      ("PuzzleSolver module with move validation")
      ("StateDiff module for state comparison")
      ("Comprehensive documentation (2400+ lines)")
      ("50+ Just recipes for build automation")
      ("9 example programs")
      ("Test suites covering core functionality")
      ("Zero npm dependencies - pure Deno")
      ("ReScript type safety throughout"))

     (partial-features
      ("Puzzle Loader - exists but not fully CLI-integrated")
      ("Interactive mode - stub exists at CLI.res:143-167"))

     (not-implemented
      ("Interactive CLI puzzle solving mode")
      ("Web interface (Deno Fresh)")
      ("Visual debugger")
      ("REPL")
      ("Performance optimization passes")
      ("Formal verification")
      ("Puzzle editor UI")))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; ROUTE TO MVP v1
    ;;; ═══════════════════════════════════════════════════════════════════

    (mvp-route
     (description . "Transform theoretical VM into playable puzzle game")
     (estimated-scope . "medium - high-value low-risk work")

     (steps
      ((step . 1)
       (name . "Implement Interactive Input Loop")
       (file . "src/CLI.res")
       (lines . "143-167")
       (tasks
        ("Add blocking stdin read for user commands")
        ("Parse instruction syntax: ADD x y, SWAP a b, etc")
        ("Handle special commands: undo, hint, quit, status")
        ("Display prompt with move count and state summary")))

      ((step . 2)
       (name . "Wire PuzzleSolver to CLI")
       (tasks
        ("Import PuzzleSolver module into CLI")
        ("Call PuzzleSolver.create with loaded puzzle")
        ("Use PuzzleSolver.executeMove for user commands")
        ("Use PuzzleSolver.undoMove for undo command")
        ("Use PuzzleSolver.printStatus for state display")))

      ((step . 3)
       (name . "Add State Visualization")
       (tasks
        ("Pretty-print current state with variable names and values")
        ("Show goal state for side-by-side comparison")
        ("Display remaining moves vs max moves")
        ("Integrate StateDiff for highlighting changes")))

      ((step . 4)
       (name . "Victory Condition and Scoring")
       (tasks
        ("Detect when current state matches goal state")
        ("Display congratulations message")
        ("Calculate score: moves-used vs par/gold/platinum")
        ("Show time taken if desired")))

      ((step . 5)
       (name . "Error Handling and Edge Cases")
       (tasks
        ("Invalid instruction syntax - clear error message")
        ("Non-existent variable references")
        ("Move limit exceeded warning and enforcement")
        ("Puzzle not found graceful handling")
        ("Division by zero and other edge cases")))

      ((step . 6)
       (name . "Integration Testing")
       (tasks
        ("Solve beginner_01_simple_add interactively")
        ("Verify undo works mid-puzzle")
        ("Test move limit enforcement")
        ("Confirm score calculation accuracy")
        ("Run through all 26 puzzles for validation")))))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; KNOWN ISSUES
    ;;; ═══════════════════════════════════════════════════════════════════

    (issues
     ((id . "ISS-001")
      (severity . "critical")
      (title . "Interactive puzzle mode not implemented")
      (file . "src/CLI.res")
      (lines . "143-167")
      (description . "When running 'just puzzle <name>', puzzle loads but interactive solving loop is missing")
      (impact . "MVP cannot be used to actually solve puzzles")
      (status . "open"))

     ((id . "ISS-002")
      (severity . "medium")
      (title . "XOR instruction potential precision issue")
      (file . "src/core/instructions/Xor.res")
      (lines . "8-22")
      (description . "ReScript bitwise operators (lor land lnot) may not work correctly for large numbers in JS")
      (recommendation . "Consider using JavaScript native ^ operator via FFI")
      (status . "needs-investigation"))

     ((id . "ISS-003")
      (severity . "low")
      (title . "MUL/DIV reversibility limitations")
      (files . ("src/core/instructions/Mul.res" "src/core/instructions/Div.res"))
      (description . "MUL requires ancilla=0, DIV makeInPlace explicitly marked as NOT properly reversible")
      (impact . "Limited use cases, not universally reversible")
      (status . "documented-limitation"))

     ((id . "ISS-004")
      (severity . "low")
      (title . "AND/OR ancilla initialization assumption")
      (files . ("src/core/instructions/And.res" "src/core/instructions/Or.res"))
      (description . "Inverse just clears ancilla without verifying it was 0 before execute")
      (risk . "Reversibility breaks if used incorrectly")
      (status . "needs-runtime-validation"))

     ((id . "ISS-005")
      (severity . "low")
      (title . "DIV by zero recovery unclear")
      (file . "src/core/instructions/Div.res")
      (lines . "16-19")
      (description . "Division by zero stores error state but inverse may not recover correctly")
      (status . "needs-investigation")))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; QUESTIONS FOR USER
    ;;; ═══════════════════════════════════════════════════════════════════

    (questions
     ((id . "Q-001")
      (priority . "high")
      (question . "Should MVP include hints display during puzzle solving?")
      (context . "Puzzles have hints defined in JSON but display mechanism not implemented")
      (options . ("Show hint on 'hint' command" "Show after N failed attempts" "Disable for MVP")))

     ((id . "Q-002")
      (priority . "high")
      (question . "What input format for instructions during interactive mode?")
      (options . ("ADD x y" "add x y" "(add x y)" "x += y")))

     ((id . "Q-003")
      (priority . "medium")
      (question . "Should undo be unlimited or limited to match forward move count?")
      (context . "Currently VM.undo exists but policy not defined"))

     ((id . "Q-004")
      (priority . "medium")
      (question . "Target platform for web interface in v3.0?")
      (options . ("Deno Fresh" "Astro" "Plain HTML/JS" "Other")))

     ((id . "Q-005")
      (priority . "low")
      (question . "Should we add puzzle difficulty ratings beyond beginner/intermediate/advanced/expert?")
      (context . "Could add numeric rating 1-10 or time-to-complete estimates"))

     ((id . "Q-006")
      (priority . "low")
      (question . "Interest in WASM compilation for browser-native performance?")
      (context . "ReScript can compile to JS which runs in browser, but WASM could be faster")))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; LONG-TERM ROADMAP
    ;;; ═══════════════════════════════════════════════════════════════════

    (roadmap
     (vision . "Educational platform for reversible computing with puzzle-based learning")

     (phases
      ((version . "2.1.0")
       (name . "Interactive MVP")
       (status . "next")
       (goals
        ("Complete interactive CLI puzzle mode")
        ("State visualization during solving")
        ("Score tracking and display")
        ("Hint system integration")))

      ((version . "2.2.0")
       (name . "Polish and Content")
       (status . "planned")
       (goals
        ("REPL for freeform experimentation")
        ("Additional puzzles (target: 50 total)")
        ("Puzzle difficulty balancing")
        ("Performance benchmarking suite")
        ("Improved error messages")))

      ((version . "2.3.0")
       (name . "Developer Experience")
       (status . "planned")
       (goals
        ("Visual debugger - step through execution")
        ("Execution trace visualization")
        ("Puzzle creation wizard CLI")
        ("Auto-solver for validation")))

      ((version . "3.0.0")
       (name . "Web Platform")
       (status . "planned")
       (goals
        ("Deno Fresh web interface")
        ("Interactive puzzle solving in browser")
        ("User accounts and progress tracking")
        ("Leaderboards for puzzle completion")
        ("Share custom puzzles")))

      ((version . "3.1.0")
       (name . "Advanced Features")
       (status . "future")
       (goals
        ("Formal verification of instruction reversibility")
        ("Optimization passes for move sequences")
        ("Multi-register state visualization")
        ("Animation of state transitions")))

      ((version . "4.0.0")
       (name . "Educational Platform")
       (status . "future")
       (goals
        ("Curriculum for reversible computing courses")
        ("Integration with learning management systems")
        ("Quantum computing introduction modules")
        ("Research paper and academic citations")))))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; PROJECT CATALOG
    ;;; ═══════════════════════════════════════════════════════════════════

    (projects
     ((name . "idaptiky-core")
      (status . "complete")
      (completion . 100)
      (category . "vm-engine")
      (phase . "released")
      (description . "Core reversible VM with 13 instructions"))

     ((name . "idaptiky-puzzles")
      (status . "complete")
      (completion . 100)
      (category . "content")
      (phase . "released")
      (description . "26 puzzle definitions from beginner to expert"))

     ((name . "idaptiky-cli-interactive")
      (status . "in-progress")
      (completion . 20)
      (category . "user-interface")
      (phase . "development")
      (description . "Interactive puzzle-solving CLI mode")
      (blockers . ("stdin input handling in Deno"))
      (next-action . "Implement input loop in CLI.res"))

     ((name . "idaptiky-documentation")
      (status . "complete")
      (completion . 95)
      (category . "documentation")
      (phase . "released")
      (description . "2400+ lines of docs, tutorials, API reference"))

     ((name . "idaptiky-web")
      (status . "paused")
      (completion . 0)
      (category . "user-interface")
      (phase . "design")
      (description . "Web interface with Deno Fresh")
      (dependencies . ("idaptiky-cli-interactive"))))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; HISTORY
    ;;; ═══════════════════════════════════════════════════════════════════

    (history
     ((date . "2025-11-21")
      (event . "v2.0.0 released")
      (notes . "Complete rewrite from TypeScript/Bun to ReScript/Deno"))

     ((date . "2025-12-08")
      (event . "STATE.scm created")
      (notes . "Initial project state checkpoint for AI collaboration")))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; CRITICAL NEXT ACTIONS
    ;;; ═══════════════════════════════════════════════════════════════════

    (critical-next
     ((priority . 1)
      (action . "Implement stdin input loop in src/CLI.res")
      (rationale . "Blocks all interactive functionality"))

     ((priority . 2)
      (action . "Parse and validate user instruction commands")
      (rationale . "Required for puzzle solving"))

     ((priority . 3)
      (action . "Wire PuzzleSolver.executeMove to CLI")
      (rationale . "Connects existing solver logic to user interface"))

     ((priority . 4)
      (action . "Add victory detection and scoring display")
      (rationale . "Completes the puzzle-solving experience"))

     ((priority . 5)
      (action . "Test with beginner puzzles end-to-end")
      (rationale . "Validates MVP is functional")))

    ;;; ═══════════════════════════════════════════════════════════════════
    ;;; FILES MODIFIED THIS SESSION
    ;;; ═══════════════════════════════════════════════════════════════════

    (files-modified
     ((file . "STATE.scm")
      (action . "created")
      (reason . "Initial project state checkpoint")))))

;;; ═══════════════════════════════════════════════════════════════════════
;;; QUERY INTERFACE (for future sessions)
;;; ═══════════════════════════════════════════════════════════════════════

;;; Available queries:
;;; (query-focus state)          → current project and phase
;;; (query-blocked state)        → all blocked projects with reasons
;;; (query-mvp-steps state)      → ordered list of MVP completion steps
;;; (query-issues state)         → all open issues by severity
;;; (query-questions state)      → unanswered questions for user

;;; ═══════════════════════════════════════════════════════════════════════
;;; LICENSE
;;; ═══════════════════════════════════════════════════════════════════════

;;; SPDX-License-Identifier: MIT OR LicenseRef-Palimpsest-0.8
;;; Copyright (c) 2025 hyperpolymath
