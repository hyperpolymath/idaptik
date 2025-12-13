import { Instruction } from "../instruction";

export class Noop implements Instruction {
  type = "NOOP";
  args: [] = [];

  execute(_: Record<string, number>) {}
  invert(_: Record<string, number>) {}
}
