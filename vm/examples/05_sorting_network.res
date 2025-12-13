// Example 5: Sorting Network (3 elements)
// Reversible sorting using compare-and-swap

let sortThree = (a: int, b: int, c: int): unit => {
  Js.Console.log(`=== Example 5: Sort Three Numbers [${Belt.Int.toString(a)}, ${Belt.Int.toString(b)}, ${Belt.Int.toString(c)}] ===\n`)

  let state = State.createState(~variables=["a", "b", "c", "temp"], ~initialValue=0)
  Js.Dict.set(state, "a", a)
  Js.Dict.set(state, "b", b)
  Js.Dict.set(state, "c", c)

  let vm = VM.make(state)

  Js.Console.log("Initial order:")
  Js.Console.log(`  [${Belt.Int.toString(a)}, ${Belt.Int.toString(b)}, ${Belt.Int.toString(c)}]`)

  // Helper: conditional swap (if a > b, swap them)
  let conditionalSwap = (var1: string, var2: string): unit => {
    let val1 = Js.Dict.get(VM.getCurrentState(vm), var1)->Belt.Option.getWithDefault(0)
    let val2 = Js.Dict.get(VM.getCurrentState(vm), var2)->Belt.Option.getWithDefault(0)

    if val1 > val2 {
      VM.run(vm, Swap.make(var1, var2))
      Js.Console.log(`  Swapped ${var1} and ${var2}`)
    }
  }

  Js.Console.log("\nSorting steps:")

  // Sorting network for 3 elements
  conditionalSwap("a", "b")  // Ensure a ≤ b
  conditionalSwap("b", "c")  // Ensure b ≤ c
  conditionalSwap("a", "b")  // Final adjustment

  let finalA = Js.Dict.get(VM.getCurrentState(vm), "a")->Belt.Option.getWithDefault(0)
  let finalB = Js.Dict.get(VM.getCurrentState(vm), "b")->Belt.Option.getWithDefault(0)
  let finalC = Js.Dict.get(VM.getCurrentState(vm), "c")->Belt.Option.getWithDefault(0)

  Js.Console.log(`\nSorted order:`)
  Js.Console.log(`  [${Belt.Int.toString(finalA)}, ${Belt.Int.toString(finalB)}, ${Belt.Int.toString(finalC)}]`)
  Js.Console.log("\n✓ Sorted using reversible compare-and-swap!")
}

// Example: Sort [30, 10, 20] → [10, 20, 30]
sortThree(30, 10, 20)
