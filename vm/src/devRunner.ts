// interpreter.ts
// Modular, recursive reversible logic interpreter
// ------------------------------------------------
// This dispatcher routes logic steps to their appropriate domain-specific implementations.
// It supports binary (active), ternary (stub), and natlog (stub) domains.
// Each domain lives in its own file and exports a registry of gate functions.

import { binaryGates } from './gates/binary';
import { ternaryGates } from './gates/ternary';
import { natlogGates } from './gates/natlog';

// -----------------------------------------------------------------------------
// 🧠 Shared Types
// -----------------------------------------------------------------------------

// Allowed domains that a step or puzzle can specify.
export type LogicDomain = 'binary' | 'ternary' | 'natlog';

// Value types for each logic family
export type Bit = 0 | 1;
export type Trit = 0 | 1 | 2;
export type NatSymbol = number; // Placeholder for more complex symbolic types later

// A single logic step: can be atomic (e.g. flip) or recursive (e.g. seq)
export interface GateOp {
  domain?: LogicDomain;          // Optional at step-level (falls back to puzzle default)
  op: string;                    // Gate name (e.g. "flip", "xor", "rot")
  target?: string;              // Single target variable (e.g. "bit0")
  targets?: string[];           // Multiple input variables (e.g. ["a", "b"])
  result?: string;              // Optional output variable (e.g. for XOR)
  steps?: GateOp[];             // Sub-steps for compound operations like "seq"
}

// The interpreter state maps variable names to their values (type depends on domain)
export type State<T extends number> = Record<string, T>;

// Each gate function takes the current step and updates the state in-place
export type GateFn<T extends number> = (step: GateOp, state: State<T>) => void;

// -----------------------------------------------------------------------------
// 🚦 Universal Dispatcher
// -----------------------------------------------------------------------------

/**
 * evaluate()
 * -----------------------
 * Executes a single logic step by:
 * 1. Determining the domain (either per-step or puzzle-level default)
 * 2. Selecting the correct gate registry
 * 3. Looking up the operation by name
 * 4. Applying the gate function to mutate the state
 *
 * Throws descriptive errors if domain or operation are unknown.
 *
 * @param step - A single operation (e.g. { op: "flip", target: "bitA" })
 * @param state - The current working state for the puzzle
 * @param puzzleDefaultDomain - The fallback domain if the step doesn’t specify one
 */
export function evaluate<T extends number>(
  step: GateOp,
  state: State<T>,
  puzzleDefaultDomain: LogicDomain
): void {
  // Determine which domain this step uses
  const domain = step.domain ?? puzzleDefaultDomain;

  // Dispatch to the appropriate gate registry
  const registry =
    domain === 'binary' ? (binaryGates as Record<string, GateFn<T>>) :
    domain === 'ternary' ? (ternaryGates as Record<string, GateFn<T>>) :
    domain === 'natlog'  ? (natlogGates  as Record<string, GateFn<T>>) :
    undefined;

  if (!registry) {
    throw new Error(`🟥 Unknown logic domain: '${domain}'`);
  }

  // Find the gate operation in the registry
  const fn = registry[step.op];
  if (!fn) {
    throw new Error(`🟥 Unsupported operation '${step.op}' in domain '${domain}'`);
  }

  // Run the gate logic on this step + state
  fn(step, state);
}
