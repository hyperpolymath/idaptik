// Benchmark suite for Idaptik VM

@val @scope("Date") external now: unit => float = "now"

// Benchmark helper
let benchmark = (name: string, iterations: int, fn: unit => unit): unit => {
  // Warm up
  for _ in 1 to 100 {
    fn()
  }

  // Actual benchmark
  let startTime = now()

  for _ in 1 to iterations {
    fn()
  }

  let endTime = now()
  let totalTime = endTime -. startTime
  let avgTime = totalTime /. float_of_int(iterations)

  Js.Console.log(`${name}:`)
  Js.Console.log(`  Total: ${Float.toString(totalTime)} ms`)
  Js.Console.log(`  Iterations: ${Belt.Int.toString(iterations)}`)
  Js.Console.log(`  Average: ${Float.toString(avgTime)} ms per iteration`)
  Js.Console.log(`  Throughput: ${Float.toString(1000.0 /. avgTime)} ops/sec`)
  Js.Console.log("")
}

// Benchmark ADD instruction
let benchmarkAdd = (): unit => {
  let state = State.createState(~variables=["x", "y"], ())
  Js.Dict.set(state, "x", 10)
  Js.Dict.set(state, "y", 5)

  let instr = Add.make("x", "y")

  benchmark("ADD execute", 100000, () => {
    instr.execute(state)
  })
}

// Benchmark SWAP instruction
let benchmarkSwap = (): unit => {
  let state = State.createState(~variables=["x", "y"], ())
  Js.Dict.set(state, "x", 10)
  Js.Dict.set(state, "y", 20)

  let instr = Swap.make("x", "y")

  benchmark("SWAP execute", 100000, () => {
    instr.execute(state)
  })
}

// Benchmark VM execution
let benchmarkVM = (): unit => {
  let state = State.createState(~variables=["x", "y", "z"], ())
  Js.Dict.set(state, "x", 10)
  Js.Dict.set(state, "y", 5)

  let vm = VM.make(state)

  benchmark("VM run (ADD)", 50000, () => {
    VM.run(vm, Add.make("x", "y"))
  })
}

// Benchmark state cloning
let benchmarkStateClone = (): unit => {
  let state = State.createState(~variables=["a", "b", "c", "d", "e", "f", "g", "h"], ())
  for i in 0 to 7 {
    let vars = ["a", "b", "c", "d", "e", "f", "g", "h"]
    Js.Dict.set(state, Belt.Array.getExn(vars, i), i * 10)
  }

  benchmark("State clone (8 vars)", 50000, () => {
    let _ = State.cloneState(state)
  })
}

// Benchmark undo operation
let benchmarkUndo = (): unit => {
  let state = State.createState(~variables=["x", "y"], ())
  let vm = VM.make(state)

  // Build up history
  for i in 1 to 100 {
    VM.run(vm, Add.make("x", "y"))
  }

  benchmark("VM undo", 50000, () => {
    VM.run(vm, Add.make("x", "y"))
    VM.undo(vm)->ignore
  })
}

// Run all benchmarks
let runAll = (): unit => {
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("  Idaptik VM Benchmarks")
  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("")

  benchmarkAdd()
  benchmarkSwap()
  benchmarkVM()
  benchmarkStateClone()
  benchmarkUndo()

  Js.Console.log("═══════════════════════════════════════")
  Js.Console.log("  Benchmarks Complete")
  Js.Console.log("═══════════════════════════════════════")
}

// Run benchmarks
runAll()
