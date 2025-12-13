import { Instruction } from "./instruction";

export class ReversibleVM {
  state: Record<string, number>;
  history: Instruction[] = [];

  constructor(initial: Record<string, number>) {
    this.state = { ...initial };
  }

  run(instr: Instruction) {
    instr.execute(this.state);
    this.history.push(instr);
  }

  undo() {
    const instr = this.history.pop();
    if (instr) instr.invert(this.state);
  }

  printState() {
    console.log("Current State:", this.state);
  }
}
