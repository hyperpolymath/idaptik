// core/state.ts

// Create a register state from a list of variable names
export function createState(
  variables: string[],
  initialValue = 0
): Record<string, number> {
  return Object.fromEntries(variables.map(v => [v, initialValue]));
}

// Deep clone the current state (for logging, snapshots, etc.)
export function cloneState(
  state: Record<string, number>
): Record<string, number> {
  return JSON.parse(JSON.stringify(state));
}

// Check if two states are equal (used in puzzle goals)
export function statesMatch(
  a: Record<string, number>,
  b: Record<string, number>
): boolean {
  const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
  return Array.from(keys).every(k => a[k] === b[k]);
}

// Serialize state to JSON string
export function serializeState(state: Record<string, number>): string {
  return JSON.stringify(state);
}

// Deserialize state from JSON string
export function deserializeState(json: string): Record<string, number> {
  return JSON.parse(json);
}
