// scripts/check-env.ts

import { execSync } from "child_process";
import chalk from "chalk";

type Tool = {
  name: string;
  command: string;
  versionFlag?: string;
  minVersion?: string;
};

const tools: Tool[] = [
  { name: "Node.js", command: "node", versionFlag: "--version", minVersion: "18.0.0" },
  { name: "npm", command: "npm", versionFlag: "--version", minVersion: "9.0.0" },
  { name: "TypeScript", command: "tsc", versionFlag: "--version", minVersion: "5.0.0" },
  { name: "Elixir", command: "elixir", versionFlag: "--version", minVersion: "1.14.0" },
  { name: "Erlang", command: "erl", versionFlag: "-noshell -eval 'io:fwrite(\"~s\", [erlang:system_info(otp_release)]).' -s init stop" },
  { name: "Mix", command: "mix", versionFlag: "--version" },
  { name: "Git", command: "git", versionFlag: "--version" },
  { name: "VS Code", command: "code", versionFlag: "--version" }
];

function checkTool(tool: Tool) {
  try {
    const versionCommand = `${tool.command} ${tool.versionFlag ?? "--version"}`;
    const output = execSync(versionCommand).toString().trim().split(/\r?\n/)[0];

    console.log(`${chalk.green("✔")} ${tool.name} detected: ${chalk.bold(output)}`);
  } catch (err) {
    console.log(`${chalk.red("✘")} ${tool.name} not found`);
  }
}

console.log(chalk.cyanBright("\n🔍 Checking your development environment...\n"));
tools.forEach(checkTool);
console.log(chalk.gray("\nIf any ✘ appear above, check the README or onboarding scripts for guidance.\n"));
