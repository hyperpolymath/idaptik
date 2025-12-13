// Example 3: XOR Swap Trick
// Classic CS algorithm: swap without temp variable

let xorSwap = (): unit => {
  Js.Console.log("=== Example 3: XOR Swap Trick ===\n")

  let state = State.createState(~variables=["a", "b"], ~initialValue=0)
  Js.Dict.set(state, "a", 42)
  Js.Dict.set(state, "b", 17)

  let vm = VM.make(state)

  Js.Console.log("Initial:")
  Js.Console.log(`  a = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "a")->Belt.Option.getWithDefault(0))}`)
  Js.Console.log(`  b = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "b")->Belt.Option.getWithDefault(0))}`)

  // XOR swap algorithm
  Js.Console.log("\nStep 1: a = a XOR b")
  VM.run(vm, Xor.make("a", "b"))

  Js.Console.log("Step 2: b = a XOR b")
  VM.run(vm, Xor.make("b", "a"))

  Js.Console.log("Step 3: a = a XOR b")
  VM.run(vm, Xor.make("a", "b"))

  Js.Console.log("\nFinal:")
  Js.Console.log(`  a = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "a")->Belt.Option.getWithDefault(0))}`)
  Js.Console.log(`  b = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "b")->Belt.Option.getWithDefault(0))}`)

  Js.Console.log("\n✓ Swapped using only XOR (no temp variable)!")
}

xorSwap()
