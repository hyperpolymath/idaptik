// StateDiff.res - Visual state comparison and diff utilities

type diff = {
  variable: string,
  before: option<int>,
  after: option<int>,
  changed: bool,
}

// Compare two states and generate diff
let computeDiff = (before: Js.Dict.t<int>, after: Js.Dict.t<int>): array<diff> => {
  // Get all unique variable names from both states
  let beforeKeys = Js.Dict.keys(before)
  let afterKeys = Js.Dict.keys(after)
  let allKeys = Belt.Array.concatMany([beforeKeys, afterKeys])
    ->Belt.Set.String.fromArray
    ->Belt.Set.String.toArray

  // Create diff for each variable
  allKeys->Belt.Array.map(variable => {
    let beforeVal = Js.Dict.get(before, variable)
    let afterVal = Js.Dict.get(after, variable)

    let changed = switch (beforeVal, afterVal) {
    | (Some(v1), Some(v2)) => v1 != v2
    | (None, Some(_)) => true
    | (Some(_), None) => true
    | (None, None) => false
    }

    {
      variable,
      before: beforeVal,
      after: afterVal,
      changed,
    }
  })
}

// Pretty print a single diff entry
let printDiffEntry = (d: diff): unit => {
  if d.changed {
    let beforeStr = switch d.before {
    | Some(v) => Belt.Int.toString(v)
    | None => "∅"
    }
    let afterStr = switch d.after {
    | Some(v) => Belt.Int.toString(v)
    | None => "∅"
    }
    Js.Console.log(`  ${d.variable}: ${beforeStr} → ${afterStr} ⚡`)
  } else {
    switch d.before {
    | Some(v) => Js.Console.log(`  ${d.variable}: ${Belt.Int.toString(v)} (unchanged)`)
    | None => ()
    }
  }
}

// Pretty print entire diff
let printDiff = (before: Js.Dict.t<int>, after: Js.Dict.t<int>): unit => {
  let diffs = computeDiff(before, after)
  let hasChanges = diffs->Belt.Array.some(d => d.changed)

  if hasChanges {
    Js.Console.log("📊 State Changes:")
    diffs->Belt.Array.forEach(printDiffEntry)
  } else {
    Js.Console.log("📊 No state changes")
  }
}

// Count number of differences
let countChanges = (before: Js.Dict.t<int>, after: Js.Dict.t<int>): int => {
  let diffs = computeDiff(before, after)
  diffs->Belt.Array.keep(d => d.changed)->Belt.Array.length
}

// Helper to pad string to length
let padLeft = (s: string, len: int): string => {
  let current = Js.String2.length(s)
  if current >= len {
    s
  } else {
    let padding = Js.String2.repeat(" ", len - current)
    padding ++ s
  }
}

let padRight = (s: string, len: int): string => {
  let current = Js.String2.length(s)
  if current >= len {
    s
  } else {
    let padding = Js.String2.repeat(" ", len - current)
    s ++ padding
  }
}

// Side-by-side comparison
let printSideBySide = (before: Js.Dict.t<int>, after: Js.Dict.t<int>): unit => {
  let diffs = computeDiff(before, after)

  Js.Console.log("╔═══════════╦═════════╦═════════╗")
  Js.Console.log("║ Variable  ║ Before  ║ After   ║")
  Js.Console.log("╠═══════════╬═════════╬═════════╣")

  diffs->Belt.Array.forEach(d => {
    let beforeStr = switch d.before {
    | Some(v) => padLeft(Belt.Int.toString(v), 7)
    | None => "   ∅   "
    }
    let afterStr = switch d.after {
    | Some(v) => padLeft(Belt.Int.toString(v), 7)
    | None => "   ∅   "
    }
    let varPadded = padRight(d.variable, 9)
    let changeIndicator = if d.changed { "⚡" } else { " " }

    Js.Console.log(`║ ${varPadded} ║ ${beforeStr} ║ ${afterStr} ║ ${changeIndicator}`)
  })

  Js.Console.log("╚═══════════╩═════════╩═════════╝")
}

// Check if all specified variables match target values
let matchesTarget = (
  current: Js.Dict.t<int>,
  target: Js.Dict.t<int>,
): bool => {
  State.statesMatch(current, target)
}

// Get variables that don't match target
let getMismatches = (
  current: Js.Dict.t<int>,
  target: Js.Dict.t<int>,
): array<string> => {
  let targetKeys = Js.Dict.keys(target)

  targetKeys->Belt.Array.keep(key => {
    let currentVal = Js.Dict.get(current, key)
    let targetVal = Js.Dict.get(target, key)

    switch (currentVal, targetVal) {
    | (Some(v1), Some(v2)) => v1 != v2
    | _ => true
    }
  })
}

// Print mismatches between current and target
let printMismatches = (
  current: Js.Dict.t<int>,
  target: Js.Dict.t<int>,
): unit => {
  let mismatches = getMismatches(current, target)

  if Belt.Array.length(mismatches) == 0 {
    Js.Console.log("✓ All target values matched!")
  } else {
    Js.Console.log(`✗ ${Belt.Int.toString(Belt.Array.length(mismatches))} mismatches:`)
    mismatches->Belt.Array.forEach(key => {
      let currentVal = Js.Dict.get(current, key)->Belt.Option.getWithDefault(0)
      let targetVal = Js.Dict.get(target, key)->Belt.Option.getWithDefault(0)
      Js.Console.log(`  ${key}: ${Belt.Int.toString(currentVal)} (expected ${Belt.Int.toString(targetVal)})`)
    })
  }
}
