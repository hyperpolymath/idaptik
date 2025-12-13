import { Instruction } from "../instruction";

export class Negate implements Instruction {
  type = "NEGATE";
  constructor(public args: [string]) {}

  execute(state: Record<string, number>) {
    const [a] = this.args;
    state[a] = -state[a];
  }

  invert(state: Record<string, number>) {
    this.execute(state); // negating again undoes it
  }
}
