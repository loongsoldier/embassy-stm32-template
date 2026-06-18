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

// ── Cortex-M critical section ──────────────────────────────────────────
// Dual-core chips (H745/H747/H755/H757 with -cm4/-cm7 suffix) need HSEM
// based synchronization, so skip the single-core impl.
let is_dual_core = chip.contains("-cm");
let cortex_m_feature = if is_dual_core {
    // User must configure their own critical section (e.g. HSEM)
    // or use embassy-executor's built-in ThreadModeRawMutex.
    ""
} else {
    `"critical-section-single-core"`
};

// ── Set template variables ──────────────────────────────────────────────
variable::set("rust_target", rust_target);
variable::set("probe_chip", chip_upper);
variable::set("cortex_m_feature", cortex_m_feature);
