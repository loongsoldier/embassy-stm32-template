// Post-generation script: move CI template files into .github/
//
// ci-template/ is not matched by the `.github` ignore pattern, so it gets copied
// into the generated project. This hook moves its contents into .github/ and
// cleans up the empty ci-template/ directory.

`mkdir -p .github/workflows`;
`mv ci-template/workflows/rust.yml .github/workflows/rust.yml`;
`rmdir ci-template/workflows`;
`rmdir ci-template`;
