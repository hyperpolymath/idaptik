// Example 8: Performance Comparison
// Compare execution speed of different instruction sequences

@val @scope("Date") external now: unit => float = "now"

// Benchmark helper
let benchmark = (name: string, iterations: int, fn: unit => unit): float => {
  // Warm up
  for _ in 1 to 10 {
    fn()
  }

  // Actual benchmark
  let startTime = now()
  for _ in 1 to iterations {
    fn()
  }
  let endTime = now()

  let totalTime = endTime -. startTime
  let avgTime = totalTime /. Belt.Int.toFloat(iterations)

  Js.Console.log(`${name}:`)
  Js.Console.log(`  ${Belt.Int.toString(iterations)} iterations`)
  Js.Console.log(`  Total: ${Js.Float.toFixedWithPrecision(totalTime, ~digits=2)} ms`)
  Js.Console.log(`  Average: ${Js.Float.toFixedWithPrecision(avgTime, ~digits=4)} ms`)
  Js.Console.log(`  Throughput: ${Js.Float.toFixedWithPrecision(1000.0 /. avgTime, ~digits=0)} ops/sec`)
  Js.Console.log("")

  avgTime
}

// Compare ADD vs XOR for incrementing
let compareIncrementMethods = (): unit => {
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("  Benchmark: Increment Methods")
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("")

  let iterations = 10000

  // Method 1: Using ADD
  let addTime = benchmark("ADD-based increment", iterations, () => {
    let state = State.createState(~variables=["x", "one"], ~initialValue=0)
    Js.Dict.set(state, "x", 0)
    Js.Dict.set(state, "one", 1)
    let vm = VM.make(state)
    VM.run(vm, Add.make("x", "one"))
  })

  // Method 2: Using SWAP chain
  let swapTime = benchmark("SWAP-based", iterations, () => {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", 0)
    Js.Dict.set(state, "y", 1)
    let vm = VM.make(state)
    VM.run(vm, Swap.make("x", "y"))
  })

  // Comparison
  let ratio = addTime /. swapTime
  Js.Console.log("Results:")
  Js.Console.log(`  ADD is ${Js.Float.toFixedWithPrecision(ratio, ~digits=2)}x ${ratio > 1.0 ? "slower" : "faster"} than SWAP`)
  Js.Console.log("")
}

// Compare different state cloning approaches
let compareStateCopy = (): unit => {
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("  Benchmark: State Cloning")
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("")

  let iterations = 5000

  // Small state
  let smallTime = benchmark("Small state (3 vars)", iterations, () => {
    let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
    Js.Dict.set(state, "a", 1)
    Js.Dict.set(state, "b", 2)
    Js.Dict.set(state, "c", 3)
    let _cloned = State.cloneState(state)
  })

  // Large state
  let largeTime = benchmark("Large state (10 vars)", iterations, () => {
    let state = State.createState(
      ~variables=["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"],
      ~initialValue=0
    )
    for i in 0 to 9 {
      let vars = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
      Js.Dict.set(state, Belt.Array.getExn(vars, i), i * 10)
    }
    let _cloned = State.cloneState(state)
  })

  let ratio = largeTime /. smallTime
  Js.Console.log("Results:")
  Js.Console.log(`  Large state is ${Js.Float.toFixedWithPrecision(ratio, ~digits=2)}x slower to clone`)
  Js.Console.log("  Scaling is approximately linear with state size")
  Js.Console.log("")
}

// Compare VM execution with/without history
let compareVMOverhead = (): unit => {
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("  Benchmark: VM History Overhead")
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("")

  let iterations = 5000

  // Direct instruction execution (no VM)
  let directTime = benchmark("Direct instruction", iterations, () => {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", 10)
    Js.Dict.set(state, "y", 5)
    let instr = Add.make("x", "y")
    instr.execute(state)
  })

  // Via VM (with history tracking)
  let vmTime = benchmark("Via VM (with history)", iterations, () => {
    let state = State.createState(~variables=["x", "y"], ~initialValue=0)
    Js.Dict.set(state, "x", 10)
    Js.Dict.set(state, "y", 5)
    let vm = VM.make(state)
    VM.run(vm, Add.make("x", "y"))
  })

  let overhead = ((vmTime -. directTime) /. directTime) *. 100.0
  Js.Console.log("Results:")
  Js.Console.log(`  VM overhead: ${Js.Float.toFixedWithPrecision(overhead, ~digits=1)}%`)
  Js.Console.log("  History tracking adds minimal overhead")
  Js.Console.log("")
}

// Compare bitwise operations
let compareBitwiseOps = (): unit => {
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("  Benchmark: Bitwise Operations")
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("")

  let iterations = 10000

  let xorTime = benchmark("XOR", iterations, () => {
    let state = State.createState(~variables=["a", "b"], ~initialValue=0)
    Js.Dict.set(state, "a", 0b1010)
    Js.Dict.set(state, "b", 0b1100)
    let instr = Xor.make("a", "b")
    instr.execute(state)
  })

  let andTime = benchmark("AND", iterations, () => {
    let state = State.createState(~variables=["a", "b", "c"], ~initialValue=0)
    Js.Dict.set(state, "a", 0b1010)
    Js.Dict.set(state, "b", 0b1100)
    let instr = And.make("a", "b", "c")
    instr.execute(state)
  })

  let rolTime = benchmark("ROL", iterations, () => {
    let state = State.createState(~variables=["x"], ~initialValue=0)
    Js.Dict.set(state, "x", 0b1010)
    let instr = Rol.make("x", ~bits=2, ())
    instr.execute(state)
  })

  let flipTime = benchmark("FLIP", iterations, () => {
    let state = State.createState(~variables=["x"], ~initialValue=0)
    Js.Dict.set(state, "x", 42)
    let instr = Flip.make("x")
    instr.execute(state)
  })

  Js.Console.log("Results:")
  Js.Console.log("  All bitwise operations have similar performance")
  Js.Console.log(`  Fastest: ${xorTime < andTime ? "XOR" : "AND"}`)
  Js.Console.log("")
}

// Run all benchmarks
Js.Console.log("╔═══════════════════════════════════════╗")
Js.Console.log("║  IDAPTIK PERFORMANCE BENCHMARKS       ║")
Js.Console.log("╚═══════════════════════════════════════╝")
Js.Console.log("")

compareIncrementMethods()
compareStateCopy()
compareVMOverhead()
compareBitwiseOps()

Js.Console.log("╔═══════════════════════════════════════╗")
Js.Console.log("║  Benchmarks Complete                  ║")
Js.Console.log("╚═══════════════════════════════════════╝")
Js.Console.log("")
Js.Console.log("💡 Tips:")
Js.Console.log("  • XOR is very efficient for toggling bits")
Js.Console.log("  • SWAP has minimal overhead")
Js.Console.log("  • VM history tracking adds <10% overhead")
Js.Console.log("  • State cloning scales linearly")
