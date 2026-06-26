// STM32 embassy template — pre-generation script
// Derives all chip-specific parameters from the chip name via prefix rules.
// No hardcoded per-chip database — all STM32 chips follow uniform conventions.

let chip = variable::get("chip");

// ── Rust target derivation ──────────────────────────────────────────────
// Map chip family prefix → Cortex core → Rust target triple.
// New families (Cortex-M33/M55) must also be listed in rust-toolchain.toml.
let target_by_prefix = #{
    // Cortex-M33 (TrustZone) — longer prefixes first
    "STM32WBA": "thumbv8m.main-none-eabihf",
    // Cortex-M33 / M55
    "STM32C5": "thumbv8m.main-none-eabihf",
    "STM32H5": "thumbv8m.main-none-eabihf",
    "STM32U5": "thumbv8m.main-none-eabihf",
    "STM32U3": "thumbv8m.main-none-eabihf",
    "STM32L5": "thumbv8m.main-none-eabihf",
    "STM32N6": "thumbv8m.main-none-eabihf",
    // Cortex-M3
    "STM32F1": "thumbv7m-none-eabi",
    "STM32F2": "thumbv7m-none-eabi",
    "STM32L1": "thumbv7m-none-eabi",
    // Cortex-M0/M0+
    "STM32F0": "thumbv6m-none-eabi",
    "STM32G0": "thumbv6m-none-eabi",
    "STM32C0": "thumbv6m-none-eabi",
    "STM32U0": "thumbv6m-none-eabi",
    "STM32WB0": "thumbv6m-none-eabi",
    "STM32L0": "thumbv6m-none-eabi",
    // Everything else → Cortex-M4/M7 (default)
};

let chip_upper = chip.to_upper();

// Default: Cortex-M4/M7 (covers F3, F4, F7, G4, H7, H7RS, H7A/B, L4, L4P/Q/R/S)
let rust_target = "thumbv7em-none-eabihf";
for prefix in target_by_prefix.keys() {
    if chip_upper.starts_with(prefix) {
        rust_target = target_by_prefix[prefix];
        break;
    }
}

// ── License handling ────────────────────────────────────────────────────
// Map display names → SPDX identifiers, derive SPDX expression, and
// manage license text files (all named LICENSE-{SPDX_ID}).

let display_to_spdx = #{
    "MIT": "MIT",
    "Apache 2.0": "Apache-2.0",
    "BSD 2-Clause": "BSD-2-Clause",
    "BSD 3-Clause": "BSD-3-Clause",
    "GPL 2.0": "GPL-2.0",
    "GPL 3.0": "GPL-3.0",
    "LGPL 2.1": "LGPL-2.1",
    "LGPL 3.0": "LGPL-3.0",
    "MPL 2.0": "MPL-2.0",
    "AGPL 3.0": "AGPL-3.0",
    "CC0 1.0": "CC0-1.0",
};

let licenses = variable::get("license");

// Convert display names → SPDX identifiers.
let spdx_list = [];
for name in licenses {
    spdx_list.push(display_to_spdx[name]);
}

// Build SPDX expression for Cargo.toml (e.g. "MIT OR Apache-2.0").
// Rhai arrays in cargo-generate do not support .join(), so build manually.
let spdx = "";
let first = true;
for item in spdx_list {
    if first {
        spdx = item;
        first = false;
    } else {
        spdx = spdx + " OR " + item;
    }
}
variable::set("license-spdx", spdx);

// File management: delete unselected license files; if single license
// selected, rename its file to LICENSE.
for spdx_id in display_to_spdx.values() {
    let file_name = "LICENSE-" + spdx_id;
    if !file::exists(file_name) { continue; }

    if spdx_list.contains(spdx_id) {
        if licenses.len() == 1 {
            file::rename(file_name, "LICENSE");
        }
        // Multi-license: keep files as-is.
    } else {
        file::delete(file_name);
    }
}

// ── Set template variables ──────────────────────────────────────────────
variable::set("rust-target", rust_target);
variable::set("probe-chip", chip_upper);
