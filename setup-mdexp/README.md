# setup-mdexp

A reusable GitHub Action to download and install the [mdexp](https://github.com/mbarbin/ocaml-mdexp) literate programming tool from a GitHub release.

## Usage

```yaml
- uses: mbarbin/mdexp-actions/setup-mdexp@<ref>
  with:
    mdexp-version: 0.0.20260403
```

- The `mdexp-version` input is required and must match a published release of mdexp.
- The action will install the `mdexp` binary and add it to the `PATH` for subsequent steps.

### Compatibility Note

The `mdexp-version` input is **mandatory** and upgrading it is the responsibility of the user. Upgrades should be done carefully. We recommend making the version change in a separate pull request, and in that PR, you can verify that everything works as expected.

The version of this action (`setup-mdexp`) is tied to the version of the `mdexp` binary it installs, because the action invokes `mdexp` with specific CLI flags and options that may change between versions.

Each version of the actions defined in this repository is tested and blessed for compatibility with specific versions of `mdexp`. The compatibility is documented as a table in the repository root `../README.md`.

## Features

- Downloads the correct binary for the runner OS and architecture.
- Verifies the build attestation (if `gh` CLI is available).
- Installs to a temporary directory and updates the `PATH`.

## License

MIT. See [LICENSE](../LICENSE).
