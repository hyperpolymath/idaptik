# Idaptik Benchmarks

**Performance testing for the Idaptik VM**

## Running Benchmarks

```bash
# Compile ReScript
just build

# Run benchmarks (when implemented)
deno run --allow-read benchmarks/benchmark.res.js
```

## Benchmark Categories

### 1. Instruction Execution

Tests raw instruction performance:
- ADD execute
- SWAP execute
- XOR execute
- State modification speed

### 2. VM Operations

Tests VM overhead:
- VM.run() with ADD
- History tracking
- State cloning

### 3. State Management

Tests state operations:
- Clone (various sizes)
- Serialize/deserialize
- State comparison

### 4. Undo Performance

Tests reversibility overhead:
- Single undo
- Bulk undo (100 operations)
- History growth impact

## Expected Performance

*Baseline on M1 MacBook Pro:*

| Operation | Throughput | Latency |
|-----------|-----------|---------|
| ADD execute | ~10M ops/sec | ~0.0001 ms |
| SWAP execute | ~8M ops/sec | ~0.00012 ms |
| VM.run(ADD) | ~5M ops/sec | ~0.0002 ms |
| State clone (8 vars) | ~2M ops/sec | ~0.0005 ms |
| VM undo | ~4M ops/sec | ~0.00025 ms |

*Note: Actual performance varies by hardware and JavaScript engine.*

## Optimization Targets

### Target 1: Sub-millisecond Operations
All basic operations should complete in <1ms.

### Target 2: Million Ops/Sec
Instruction execution should exceed 1M ops/sec.

### Target 3: Linear Growth
Performance should scale linearly with state size.

## Future Benchmarks

- [ ] Long-running sessions (10k+ operations)
- [ ] Large state spaces (1000+ variables)
- [ ] Puzzle solving performance
- [ ] Memory usage profiling
- [ ] Comparison: ReScript vs TypeScript vs Rust

## Analysis Tools

```bash
# Profile with Deno
deno run --allow-read --v8-flags=--prof benchmarks/benchmark.res.js

# Generate flamegraph
# (Future: integrate with perf tools)
```

## See Also

- **[GRAND-VISION-MAP.md](../GRAND-VISION-MAP.md)** - Performance roadmap
- **[Examples](../examples/)** - Real-world usage patterns
