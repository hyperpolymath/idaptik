// Example 2: Fibonacci Sequence
// Generate first N Fibonacci numbers using reversible operations

let fibonacci = (n: int): unit => {
  Js.Console.log(`=== Example 2: Fibonacci (first ${Belt.Int.toString(n)} numbers) ===\n`)

  let state = State.createState(~variables=["a", "b", "temp"], ~initialValue=0)
  Js.Dict.set(state, "a", 0)
  Js.Dict.set(state, "b", 1)

  let vm = VM.make(state)

  Js.Console.log("Fibonacci sequence:")
  Js.Console.log(`F(0) = 0`)
  Js.Console.log(`F(1) = 1`)

  // Generate Fibonacci numbers
  for i in 2 to n {
    // temp = a + b
    VM.run(vm, Add.make("temp", "a"))  // temp = a
    VM.run(vm, Add.make("temp", "b"))  // temp = a + b

    // Shift: a = b, b = temp
    VM.run(vm, Swap.make("a", "b"))    // a = b
    VM.run(vm, Swap.make("b", "temp")) // b = temp

    let current = Js.Dict.get(VM.getCurrentState(vm), "b")->Belt.Option.getWithDefault(0)
    Js.Console.log(`F(${Belt.Int.toString(i)}) = ${Belt.Int.toString(current)}`)

    // Reset temp for next iteration
    VM.run(vm, Sub.make("temp", "temp"))
  }

  Js.Console.log("\n✓ Fibonacci generated using reversible operations!")
}

// Run example
fibonacci(10)
