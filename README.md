# embassy-stm32 template

A [cargo-generate] template for quickly scaffolding embedded Rust projects with [embassy] on STM32 microcontrollers.

## Quick start

```bash
# Install tools (one-time)
cargo install cargo-generate
cargo install just
cargo install probe-rs --features cli

# Optional: USB DFU flashing (no debug probe needed)
cargo install cargo-dfu

# Generate project
cargo generate --git https://github.com/loongsoldier/embassy-stm32-template
```

Choose your STM32 chip from the list, then:

```bash
cd <project-name>
just run
```

> **Note:** The `rust-toolchain.toml` pins **stable** Rust with all Cortex-M targets pre-configured — just run `rustup update`.

## What you get

A blinky project with everything wired up:

| Component | Details |
|-----------|---------|
| **Executor** | embassy-executor (thread mode) |
| **HAL** | embassy-stm32 with `memory-x` auto-linking |
| **Logging** | defmt + RTT (view with `probe-rs attach`) |
| **Runner** | `cargo run` → `probe-rs run` |
| **Testing** | embedded-test + probe-rs (target hardware) |
| **Task runner** | `just run` / `just test` / `just bloat` / `just size` / `just erase` |

```
my-project/
├── .cargo/config.toml    # probe-rs / DFU runner, build target
├── Cargo.toml
├── build.rs              # linker scripts (bin + test targets)
├── justfile              # just build / run / test / size / bloat / erase
├── rust-toolchain.toml   # stable + all Cortex-M targets
├── src/
│   └── main.rs           # blinky template
├── tests/
│   └── example_test.rs   # on-target test example
└── memory.x              # auto-generated (embassy-stm32 memory-x)
```

## Supported chips

All STM32 series supported by [embassy-stm32 v0.6.0], covering **1400+** MCU part numbers:

| Cortex | Series |
|--------|--------|
| M0/M0+ | STM32F0, G0, C0, L0, U0, WB0 |
| M3 | STM32F1, F2, L1 |
| M4 | STM32F3, F4, G4, L4, WB, WL |
| M7 | STM32F7, H7, H7RS |
| M33 | STM32H5, U5, U3, L5, WBA, C5 |
| M55 | STM32N6 |

Dual-core H7 (`-cm4`/`-cm7` suffix) is supported but requires manual `critical-section` setup.

[embassy-stm32 v0.6.0]: https://crates.io/crates/embassy-stm32/0.6.0

## Commands

```bash
just build          # compile firmware
just run            # build + flash + run (probe-rs)
just dfu            # build + flash via USB DFU
just test           # build + run all tests
just test-one NAME  # run a specific test
just rebuild        # clean + build
just size           # print Flash/RAM usage
just bloat          # analyze binary size by crate
just bloat-symbols  # analyze binary size by symbol
just erase          # erase chip
just clean          # cargo clean
```

Or use standard cargo commands:

```bash
cargo build
cargo run            # probe-rs run
cargo dfu --chip stm32  # flash via USB DFU
cargo test           # probe-rs run (test mode)
cargo size
cargo bloat --crates -n 20
```

## Testing on hardware

This template includes [embedded-test] for running tests directly on the target:

```bash
# Run all tests
just test

# Run a specific test
just test-one my_test_name

# Or with cargo directly
cargo test
cargo test --test example_test -- my_test_name
```

Each test runs in isolation — the chip is reset between tests. Add new test files in `tests/` and declare them in `Cargo.toml`:

```toml
[[test]]
name = "my_test"
harness = false
```

[embedded-test]: https://github.com/probe-rs/embedded-test

## Customizing for production

- **Clock config**: Replace `Default::default()` in `main.rs` with your RCC config
- **Pin mapping**: Use embassy-stm32's GPIO API to configure peripherals
- **Time driver**: Change `time-driver-any` to a specific timer (e.g. `time-driver-tim2`) for predictable interrupt priority
- **Build optimizations**: `opt-level = 'z'` for both profiles; dev uses `lto = "thin"` + incremental for fast iteration, release uses `lto = "fat"` for minimal size

## License

MIT OR Apache-2.0

[cargo-generate]: https://github.com/cargo-generate/cargo-generate
[embassy]: https://embassy.dev
