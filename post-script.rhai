// Post-generation script: move CI template files into .github/
//
// ci-template/ is not matched by the `.github` ignore pattern, so it gets copied
// into the generated project. This hook moves its contents into .github/ and
// cleans up both ci-template/ and itself.

// Create .github/workflows/ directory by writing a temporary placeholder.
// file::write creates parent directories as needed.
file::write(".github/workflows/.gitkeep", "");

// Move the CI workflow into place (already Liquid-processed).
file::rename("ci-template/workflows/rust.yml", ".github/workflows/rust.yml");

// Clean up: remove placeholder, ci-template tree, and this script.
file::delete(".github/workflows/.gitkeep");
file::delete("ci-template/workflows");
file::delete("ci-template");
file::delete("post-script.rhai");
