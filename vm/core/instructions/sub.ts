import { Instruction } from "../instruction";

export class Sub implements Instruction {
  type = "SUB";
  constructor(public args: [string, string]) {}

  execute(state: Record<string, number>) {
    const [a, b] = this.args;
    state[a] -= state[b];
  }

  invert(state: Record<string, number>) {
    const [a, b] = this.args;
    state[a] += state[b];
  }
}
