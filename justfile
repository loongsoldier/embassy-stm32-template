mcu := "{{ probe-chip }}"
target := "{{ rust-target }}"
name := "{{ project-name }}"

elf := justfile_directory() / "target" / target / "debug" / name
elf-release := justfile_directory() / "target" / target / "release" / name

# Build debug firmware
build:
    cargo build

# Clean & rebuild debug firmware
rebuild: clean build

# Build release firmware
build-release:
    cargo build --release

# Clean & rebuild release firmware
rebuild-release: clean build-release

# Build, flash & run (debug)
run: build
    probe-rs run --chip {{ "{{" }} mcu {{ "}}" }} --connect-under-reset {{ "{{" }} elf {{ "}}" }}

# Build, flash & run (release)
run-release: build-release
    probe-rs run --chip {{ "{{" }} mcu {{ "}}" }} --connect-under-reset {{ "{{" }} elf-release {{ "}}" }}

# Print binary size (debug)
size: build
    cargo size

# Print binary size (release)
size-release: build-release
    cargo size --release

# Erase flash memory
erase:
    probe-rs erase --chip {{ "{{" }} mcu {{ "}}" }} --connect-under-reset

# Clean build artifacts
clean:
    cargo clean
