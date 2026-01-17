;; SPDX-License-Identifier: PMPL-1.0
;; STATE.scm - Project state for idaptik

(state
  (metadata
    (version "0.1.0")
    (schema-version "1.0")
    (created "2024-06-01")
    (updated "2025-01-17")
    (project "idaptik")
    (repo "hyperpolymath/idaptik"))

  (project-context
    (name "IDApTIK Core")
    (tagline "Asymmetric camera system game with Elixir multiplayer backend")
    (tech-stack ("elixir" "phoenix" "flatbuffers")))

  (current-position
    (phase "alpha")
    (overall-completion 25)
    (working-features
      ("Elixir server architecture"
       "Phoenix + Bandit stack"
       "CURP multiplayer sync"
       "FlatBuffers serialization"))))
