import { GateFn, Bit } from '../interpreter-types';

export const binaryGates: Record<string, GateFn<Bit>> = {
  flip: (step, state) => {
    if (!step.target) throw new Error("Missing target for flip");
    state[step.target] = state[step.target] ^ 1;
  },
  swap: (step, state) => {
    const [a, b] = step.targets ?? [];
    if (!(a && b)) throw new Error("Missing targets for swap");
    [state[a], state[b]] = [state[b], state[a]];
  },
  xor: (step, state) => {
    const [a, b] = step.targets ?? [];
    if (!step.result) throw new Error("Missing result for xor");
    state[step.result] = state[a] ^ state[b];
  },
  seq: (step, state) => {
    for (const sub of step.steps ?? []) {
      // You’ll wire this to your main evaluate later
      throw new Error("seq not yet linked to evaluator");
    }
  }
};
