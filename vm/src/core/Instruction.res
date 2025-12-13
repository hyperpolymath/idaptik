// Core reversible instruction interface
type t = {
  instructionType: string,
  args: array<string>,
  execute: Js.Dict.t<int> => unit,
  invert: Js.Dict.t<int> => unit,
}

// Helper to create instruction records
let make = (~instructionType, ~args, ~execute, ~invert) => {
  instructionType,
  args,
  execute,
  invert,
}
