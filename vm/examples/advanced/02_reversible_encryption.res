// Advanced Example: Reversible Encryption
// XOR-based cipher (perfectly reversible)

let encrypt = (message: int, key: int): int => {
  // XOR encryption: ciphertext = message XOR key
  Js.Int.lor(Js.Int.land(message, lnot(key)), Js.Int.land(lnot(message), key))
}

let decrypt = (ciphertext: int, key: int): int => {
  // XOR decryption: message = ciphertext XOR key
  // Same as encryption! (XOR is self-inverse)
  encrypt(ciphertext, key)
}

let reversibleEncryption = (): unit => {
  Js.Console.log("=== Reversible Encryption (XOR Cipher) ===\n")

  let state = State.createState(~variables=["plaintext", "key", "ciphertext"], ~initialValue=0)
  Js.Dict.set(state, "plaintext", 0b11010110)   // 214 in decimal
  Js.Dict.set(state, "key", 0b10101010)         // 170 in decimal (secret key)

  let vm = VM.make(state)

  let originalPlaintext = Js.Dict.get(VM.getCurrentState(vm), "plaintext")->Belt.Option.getWithDefault(0)
  let secretKey = Js.Dict.get(VM.getCurrentState(vm), "key")->Belt.Option.getWithDefault(0)

  Js.Console.log("Original message (plaintext):")
  Js.Console.log(`  Binary:  ${Belt.Int.toStringWithRadix(originalPlaintext, ~radix=2)}`)
  Js.Console.log(`  Decimal: ${Belt.Int.toString(originalPlaintext)}`)

  Js.Console.log("\nSecret key:")
  Js.Console.log(`  Binary:  ${Belt.Int.toStringWithRadix(secretKey, ~radix=2)}`)
  Js.Console.log(`  Decimal: ${Belt.Int.toString(secretKey)}`)

  // Encrypt: ciphertext = plaintext XOR key
  Js.Console.log("\n--- ENCRYPTION ---")
  VM.run(vm, Add.make("ciphertext", "plaintext"))  // Copy plaintext to ciphertext
  VM.run(vm, Xor.make("ciphertext", "key"))        // XOR with key

  let ciphertextValue = Js.Dict.get(VM.getCurrentState(vm), "ciphertext")->Belt.Option.getWithDefault(0)

  Js.Console.log("Encrypted message (ciphertext):")
  Js.Console.log(`  Binary:  ${Belt.Int.toStringWithRadix(ciphertextValue, ~radix=2)}`)
  Js.Console.log(`  Decimal: ${Belt.Int.toString(ciphertextValue)}`)

  // Decrypt: plaintext = ciphertext XOR key
  Js.Console.log("\n--- DECRYPTION ---")

  // Zero out plaintext first
  VM.run(vm, Sub.make("plaintext", "plaintext"))

  // Decrypt
  VM.run(vm, Add.make("plaintext", "ciphertext"))  // Copy ciphertext
  VM.run(vm, Xor.make("plaintext", "key"))         // XOR with key

  let decryptedValue = Js.Dict.get(VM.getCurrentState(vm), "plaintext")->Belt.Option.getWithDefault(0)

  Js.Console.log("Decrypted message:")
  Js.Console.log(`  Binary:  ${Belt.Int.toStringWithRadix(decryptedValue, ~radix=2)}`)
  Js.Console.log(`  Decimal: ${Belt.Int.toString(decryptedValue)}`)

  Js.Console.log("\n✓ Perfect reversibility!")
  Js.Console.log(`Original: ${Belt.Int.toString(originalPlaintext)}, Decrypted: ${Belt.Int.toString(decryptedValue)}`)

  if originalPlaintext == decryptedValue {
    Js.Console.log("✓ Encryption and decryption successful!")
  } else {
    Js.Console.log("✗ Error in encryption/decryption")
  }

  Js.Console.log("\nSecurity Note:")
  Js.Console.log("XOR cipher is only secure if key is:")
  Js.Console.log("  1. Truly random")
  Js.Console.log("  2. Same length as message")
  Js.Console.log("  3. Used only once (one-time pad)")
}

reversibleEncryption()
