/* tslint:disable */
/* eslint-disable */
/**
 * WASM-exported game instance
 */
export class WasmGame {
  free(): void;
  [Symbol.dispose](): void;
  /**
   * Spawn a guard and return their ID
   */
  spawnGuard(x: number, y: number): number;
  /**
   * Add an obstacle to the world
   */
  addObstacle(x: number, y: number, radius: number): void;
  /**
   * Spawn a player and return their ID
   */
  spawnPlayer(x: number, y: number): number;
  /**
   * Apply player input
   */
  applyPlayerInput(player_id: number, move_x: number, move_y: number, sprint: boolean, crouch: boolean, prone: boolean): void;
  /**
   * Create a new game instance
   */
  constructor(width: number, height: number);
  /**
   * Update game state
   * Returns JSON array of game events
   */
  update(delta_time: number): string;
  /**
   * Get game time
   */
  getTime(): number;
  /**
   * Add a light source
   */
  addLight(x: number, y: number, radius: number, intensity: number): void;
  /**
   * Get current game state as JSON
   */
  getState(): string;
  /**
   * Set game state from JSON (for network sync)
   */
  setState(state_json: string): boolean;
}

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
  readonly memory: WebAssembly.Memory;
  readonly __wbg_wasmgame_free: (a: number, b: number) => void;
  readonly wasmgame_addLight: (a: number, b: number, c: number, d: number, e: number) => void;
  readonly wasmgame_addObstacle: (a: number, b: number, c: number, d: number) => void;
  readonly wasmgame_applyPlayerInput: (a: number, b: number, c: number, d: number, e: number, f: number, g: number) => void;
  readonly wasmgame_getState: (a: number) => [number, number];
  readonly wasmgame_getTime: (a: number) => number;
  readonly wasmgame_new: (a: number, b: number) => number;
  readonly wasmgame_setState: (a: number, b: number, c: number) => number;
  readonly wasmgame_spawnGuard: (a: number, b: number, c: number) => number;
  readonly wasmgame_spawnPlayer: (a: number, b: number, c: number) => number;
  readonly wasmgame_update: (a: number, b: number) => [number, number];
  readonly __wbindgen_free: (a: number, b: number, c: number) => void;
  readonly __wbindgen_malloc: (a: number, b: number) => number;
  readonly __wbindgen_realloc: (a: number, b: number, c: number, d: number) => number;
  readonly __wbindgen_externrefs: WebAssembly.Table;
  readonly __wbindgen_start: () => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;
/**
* Instantiates the given `module`, which can either be bytes or
* a precompiled `WebAssembly.Module`.
*
* @param {{ module: SyncInitInput }} module - Passing `SyncInitInput` directly is deprecated.
*
* @returns {InitOutput}
*/
export function initSync(module: { module: SyncInitInput } | SyncInitInput): InitOutput;

/**
* If `module_or_path` is {RequestInfo} or {URL}, makes a request and
* for everything else, calls `WebAssembly.instantiate` directly.
*
* @param {{ module_or_path: InitInput | Promise<InitInput> }} module_or_path - Passing `InitInput` directly is deprecated.
*
* @returns {Promise<InitOutput>}
*/
export default function __wbg_init (module_or_path?: { module_or_path: InitInput | Promise<InitInput> } | InitInput | Promise<InitInput>): Promise<InitOutput>;
