// Post-generation script: rename ci-template/ → .github/
//
// ci-template/ is not matched by the `.github` ignore pattern, so it gets
// copied into the generated project. This hook renames it to .github/ and
// cleans up itself.

file::rename("ci-template", ".github");
file::delete("post-script.rhai");
