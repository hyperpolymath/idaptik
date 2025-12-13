import { Instruction } from "../instruction";

export class Swap implements Instruction {
  type = "SWAP";
  constructor(public args: [string, string]) {}

  execute(state: Record<string, number>) {
    const [a, b] = this.args;
    [state[a], state[b]] = [state[b], state[a]];
  }

  invert(state: Record<string, number>) {
    this.execute(state); // swap is its own inverse
  }
}
