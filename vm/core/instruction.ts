export interface Instruction {
  type: string;
  args: string[];
  execute(state: Record<string, number>): void;
  invert(state: Record<string, number>): void;
}
