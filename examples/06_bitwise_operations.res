// Example 6: Bitwise Operations
// Demonstrates XOR, AND, OR, FLIP, ROL, ROR instructions

// Bitwise XOR cipher (one-time pad)
let xorCipher = (): unit => {
  Js.Console.log("=== XOR Cipher ===")

  let state = State.createState(~variables=["plaintext", "key", "ciphertext"], ~initialValue=0)
  Js.Dict.set(state, "plaintext", 0b10101010)  // Message: 170
  Js.Dict.set(state, "key", 0b11001100)        // Key: 204

  let vm = VM.make(state)

  Js.Console.log("Plaintext:", 0b10101010)
  Js.Console.log("Key:", 0b11001100)

  // Encrypt: ciphertext = plaintext XOR key
  VM.run(vm, Add.make("ciphertext", "plaintext"))
  VM.run(vm, Xor.make("ciphertext", "key"))

  let encrypted = Js.Dict.get(state, "ciphertext")->Belt.Option.getWithDefault(0)
  Js.Console.log("Encrypted:", encrypted)

  // Decrypt: plaintext = ciphertext XOR key
  Js.Dict.set(state, "plaintext", 0)  // Clear plaintext
  VM.run(vm, Add.make("plaintext", "ciphertext"))
  VM.run(vm, Xor.make("plaintext", "key"))

  let decrypted = Js.Dict.get(state, "plaintext")->Belt.Option.getWithDefault(0)
  Js.Console.log("Decrypted:", decrypted)
  Js.Console.log("")
}

// AND and OR gates with ancilla
let logicGates = (): unit => {
  Js.Console.log("=== Logic Gates ===")

  let state = State.createState(~variables=["a", "b", "and_result", "or_result"], ~initialValue=0)
  Js.Dict.set(state, "a", 0b1100)
  Js.Dict.set(state, "b", 0b1010)

  let vm = VM.make(state)

  Js.Console.log("a = 0b1100 (12)")
  Js.Console.log("b = 0b1010 (10)")

  // AND gate
  VM.run(vm, And.make("a", "b", "and_result"))
  let andRes = Js.Dict.get(state, "and_result")->Belt.Option.getWithDefault(0)
  Js.Console.log(`a AND b = ${Belt.Int.toString(andRes)} (0b${Js.Int.toStringWithRadix(andRes, ~radix=2)})`)

  // OR gate
  VM.run(vm, Or.make("a", "b", "or_result"))
  let orRes = Js.Dict.get(state, "or_result")->Belt.Option.getWithDefault(0)
  Js.Console.log(`a OR b = ${Belt.Int.toString(orRes)} (0b${Js.Int.toStringWithRadix(orRes, ~radix=2)})`)
  Js.Console.log("")
}

// Bit rotation
let bitRotation = (): unit => {
  Js.Console.log("=== Bit Rotation ===")

  let state = State.createState(~variables=["value"], ~initialValue=0)
  Js.Dict.set(state, "value", 0b11110000)

  let vm = VM.make(state)

  Js.Console.log("Initial: 0b11110000")

  // Rotate left by 2
  VM.run(vm, Rol.make("value", ~bits=2, ()))
  let afterRol = Js.Dict.get(state, "value")->Belt.Option.getWithDefault(0)
  Js.Console.log(`After ROL 2: 0b${Js.Int.toStringWithRadix(afterRol, ~radix=2)}`)

  // Rotate right by 2 (should restore)
  VM.run(vm, Ror.make("value", ~bits=2, ()))
  let afterRor = Js.Dict.get(state, "value")->Belt.Option.getWithDefault(0)
  Js.Console.log(`After ROR 2: 0b${Js.Int.toStringWithRadix(afterRor, ~radix=2)}`)

  Js.Console.log("Note: ROL and ROR are mutual inverses!")
  Js.Console.log("")
}

// Bitwise NOT (FLIP)
let bitwiseNot = (): unit => {
  Js.Console.log("=== Bitwise NOT ===")

  let state = State.createState(~variables=["x"], ~initialValue=0)
  Js.Dict.set(state, "x", 42)

  let vm = VM.make(state)

  Js.Console.log("x = 42")

  VM.run(vm, Flip.make("x"))
  let flipped = Js.Dict.get(state, "x")->Belt.Option.getWithDefault(0)
  Js.Console.log(`NOT x = ${Belt.Int.toString(flipped)}`)

  VM.run(vm, Flip.make("x"))
  let restored = Js.Dict.get(state, "x")->Belt.Option.getWithDefault(0)
  Js.Console.log(`NOT (NOT x) = ${Belt.Int.toString(restored)}`)

  Js.Console.log("Note: FLIP is self-inverse!")
  Js.Console.log("")
}

// Run all examples
xorCipher()
logicGates()
bitRotation()
bitwiseNot()

Js.Console.log("✓ All bitwise operations demonstrated!")
