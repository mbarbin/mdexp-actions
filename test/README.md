# mdexp-actions-test

This is a standalone OCaml project that uses [mdexp](https://github.com/mbarbin/ocaml-mdexp) to generate documentation from source code.

## Purpose

This project serves as an integration test for the `setup-mdexp` GitHub Action. It validates that:

1. The `setup-mdexp` action correctly installs the mdexp binary
2. The installed binary works correctly when invoked by dune
3. The mdexp directives and snapshot extraction function as expected

## How it works

The project contains OCaml files with mdexp directives (e.g., `main.ml`) that generate corresponding markdown files (e.g., `main.md`). The dune rules invoke `mdexp` to perform this generation.

When the CI workflow runs:
1. `setup-mdexp` installs the mdexp binary
2. `dune build @runtest` invokes mdexp to generate markdown
3. Dune verifies the generated output matches the expected files

## Local development

To build and test locally, ensure `mdexp` is installed and run:

```sh
dune build @runtest
```
