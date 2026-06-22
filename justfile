mcu := "{{ probe-chip }}"
target := "{{ rust-target }}"
name := "{{ project-name }}"

elf := justfile_directory() / "target" / target / "debug" / name

# DFU chip family (derived from MCU, all STM32 chips use "stm32")
dfu_chip := "stm32"

# Build firmware
build:
    cargo build

# Clean & rebuild firmware
rebuild: clean build

# Build, flash & run
run: build
    probe-rs run --chip {{ "{{" }} mcu {{ "}}" }} {{ "{{" }} elf {{ "}}" }}

# Print binary size
size: build
    cargo size

# Build, flash & run via USB DFU (chip must be in DFU mode)
dfu: build
    cargo dfu --chip {{ "{{" }} dfu_chip {{ "}}" }}

# Erase flash memory
erase:
    probe-rs erase --chip {{ "{{" }} mcu {{ "}}" }}

# Run all tests (requires probe-rs + connected target)
test:
    cargo test

# Run a specific test by name
test-one test_name:
    cargo test --test example_test -- {{ "{{" }} test_name {{ "}}" }}

# Analyze binary size by crate (requires: cargo install cargo-bloat)
bloat: build
    cargo bloat --crates -n 20

# Analyze binary size by symbol
bloat-symbols: build
    cargo bloat -n 20

# Clean build artifacts
clean:
    cargo clean
