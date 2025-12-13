// Example 4: Greatest Common Divisor
// Euclidean algorithm using reversible operations

let gcd = (a: int, b: int): unit => {
  Js.Console.log(`=== Example 4: GCD of ${Belt.Int.toString(a)} and ${Belt.Int.toString(b)} ===\n`)

  let state = State.createState(~variables=["a", "b", "temp"], ~initialValue=0)
  Js.Dict.set(state, "a", a)
  Js.Dict.set(state, "b", b)

  let vm = VM.make(state)

  Js.Console.log("Euclidean Algorithm:")
  let steps = ref(0)

  // Continue while b != 0
  while Js.Dict.get(VM.getCurrentState(vm), "b")->Belt.Option.getWithDefault(0) != 0 {
    steps := steps.contents + 1

    let currentA = Js.Dict.get(VM.getCurrentState(vm), "a")->Belt.Option.getWithDefault(0)
    let currentB = Js.Dict.get(VM.getCurrentState(vm), "b")->Belt.Option.getWithDefault(0)

    Js.Console.log(`  Step ${Belt.Int.toString(steps.contents)}: a=${Belt.Int.toString(currentA)}, b=${Belt.Int.toString(currentB)}`)

    // Repeatedly subtract b from a until a < b
    while currentA >= currentB {
      VM.run(vm, Sub.make("a", "b"))
    }

    // Swap: now b has the remainder
    VM.run(vm, Swap.make("a", "b"))
  }

  let result = Js.Dict.get(VM.getCurrentState(vm), "a")->Belt.Option.getWithDefault(0)

  Js.Console.log(`\n✓ GCD = ${Belt.Int.toString(result)} (found in ${Belt.Int.toString(steps.contents)} steps)`)
}

// Example: GCD(48, 18) = 6
gcd(48, 18)
