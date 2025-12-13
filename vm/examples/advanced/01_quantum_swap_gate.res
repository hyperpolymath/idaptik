// Advanced Example: Quantum SWAP Gate Simulation
// Demonstrates how reversible operations relate to quantum computing

let quantumSwap = (): unit => {
  Js.Console.log("=== Quantum SWAP Gate Simulation ===\n")

  Js.Console.log("In quantum computing, SWAP is a fundamental gate.")
  Js.Console.log("It exchanges quantum states |ψ⟩ and |φ⟩.\n")

  // Simulate quantum register (simplified to integers)
  let state = State.createState(~variables=["qubit0", "qubit1", "ancilla"], ~initialValue=0)
  Js.Dict.set(state, "qubit0", 0b01)  // |1⟩
  Js.Dict.set(state, "qubit1", 0b10)  // |2⟩
  Js.Dict.set(state, "ancilla", 0b00) // |0⟩

  let vm = VM.make(state)

  Js.Console.log("Initial quantum states:")
  Js.Console.log(`  |qubit0⟩ = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "qubit0")->Belt.Option.getWithDefault(0))}`)
  Js.Console.log(`  |qubit1⟩ = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "qubit1")->Belt.Option.getWithDefault(0))}`)

  Js.Console.log("\nApplying quantum SWAP gate (using reversible operations):")

  // Fredkin gate: Controlled-SWAP using XOR
  // This is equivalent to a quantum SWAP gate
  VM.run(vm, Xor.make("qubit0", "qubit1"))
  Js.Console.log("  Step 1: qubit0 XOR qubit1")

  VM.run(vm, Xor.make("qubit1", "qubit0"))
  Js.Console.log("  Step 2: qubit1 XOR qubit0")

  VM.run(vm, Xor.make("qubit0", "qubit1"))
  Js.Console.log("  Step 3: qubit0 XOR qubit1")

  Js.Console.log("\nFinal quantum states:")
  Js.Console.log(`  |qubit0⟩ = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "qubit0")->Belt.Option.getWithDefault(0))}`)
  Js.Console.log(`  |qubit1⟩ = ${Belt.Int.toString(Js.Dict.get(VM.getCurrentState(vm), "qubit1")->Belt.Option.getWithDefault(0))}`)

  Js.Console.log("\n✓ Quantum SWAP gate demonstrated!")
  Js.Console.log("Note: Real quantum gates work on superpositions,")
  Js.Console.log("but the reversibility principle is the same.")
}

quantumSwap()
