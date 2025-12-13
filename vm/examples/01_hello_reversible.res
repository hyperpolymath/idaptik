// Example 1: Hello Reversible World
// Demonstrates basic ADD and reversibility

let example = (): unit => {
  Js.Console.log("=== Example 1: Hello Reversible World ===\n")

  // Create initial state
  let state = State.createState(~variables=["x", "y"], ~initialValue=0)
  Js.Dict.set(state, "x", 10)
  Js.Dict.set(state, "y", 5)

  Js.Console.log("Initial state:")
  Js.Console.log(state)

  // Create VM
  let vm = VM.make(state)

  // Forward execution
  Js.Console.log("\nForward: ADD x y")
  VM.run(vm, Add.make("x", "y"))
  Js.Console.log("After ADD:")
  Js.Console.log(VM.getCurrentState(vm))

  // Backward execution (undo)
  Js.Console.log("\nBackward: UNDO")
  VM.undo(vm)->ignore
  Js.Console.log("After UNDO:")
  Js.Console.log(VM.getCurrentState(vm))

  Js.Console.log("\n✓ Perfect reversibility demonstrated!")
}
