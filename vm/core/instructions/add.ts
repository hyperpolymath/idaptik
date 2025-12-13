import { Instruction } from "../instruction";

export class Add implements Instruction {
  type = "ADD";

  constructor(public args: [string, string]) {}

  execute(state: Record<string, number>) {
    const [a, b] = this.args;
    state[a] += state[b];
  }

  invert(state: Record<string, number>) {
    const [a, b] = this.args;
    state[a] -= state[b];
  }
}
