#!/usr/bin/env python3
"""Verify all chips in cargo-generate.toml are valid embassy-stm32 v0.6 features."""
import json
import re
import sys
import urllib.request

EMBASSY_STM32_VERSION = "0.6.0"
API_URL = f"https://crates.io/api/v1/crates/embassy-stm32/{EMBASSY_STM32_VERSION}"


def fetch_features() -> set[str]:
    req = urllib.request.Request(
        API_URL,
        headers={"User-Agent": "embassy-stm32-template-ci/1.0"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())
    features = data["version"]["features"]
    chips = set()
    for k in features:
        # Chip features start with "stm32" and don't contain "-cm" (dual-core suffix)
        if k.startswith("stm32") and "-cm" not in k and not k.startswith("stm32-"):
            chips.add(k)
    return chips


def main():
    print(f"Fetching embassy-stm32 v{EMBASSY_STM32_VERSION} features...")
    try:
        api_chips = fetch_features()
        print(f"  Supported chips in crate: {len(api_chips)}")
    except Exception as e:
        print(f"  WARNING: could not fetch API: {e}")
        print("  Skipping completeness check.")
        sys.exit(0)

    with open("cargo-generate.toml") as f:
        toml_chips = set(re.findall(r'"([a-z0-9]+)"', f.read()))

    # Only compare STM32 chips in choices
    stm32_in_toml = {c for c in toml_chips if c.startswith("stm32")}
    print(f"  Chips in cargo-generate.toml choices: {len(stm32_in_toml)}")

    missing = sorted(api_chips - stm32_in_toml)
    extra = sorted(stm32_in_toml - api_chips)

    if missing:
        print(f"\n  ✗ Missing from choices ({len(missing)}):")
        for chip in missing[:10]:
            print(f"    - {chip}")
        if len(missing) > 10:
            print(f"    ... and {len(missing) - 10} more")

    if extra:
        print(f"\n  ✗ Extra in choices (not in crate) ({len(extra)}):")
        for chip in extra[:10]:
            print(f"    - {chip}")
        if len(extra) > 10:
            print(f"    ... and {len(extra) - 10} more")

    if missing or extra:
        print(f"\n  Result: FAIL ({len(missing)} missing, {len(extra)} extra)")
        # Dual-core WL variants are intentionally skipped
        dual_core_skipped = [c for c in missing if c.startswith("stm32wl5")]
        if dual_core_skipped:
            print(f"  Note: {len(dual_core_skipped)} WL dual-core chips intentionally skipped")
        sys.exit(1)
    else:
        print(f"\n  Result: OK (all {len(stm32_in_toml)} chips valid)")


if __name__ == "__main__":
    main()
