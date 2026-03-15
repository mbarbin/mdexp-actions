# mdexp-actions Test

This file demonstrates the use of mdexp with print-table to generate
documentation tables that stay in sync with the code.

## GitHub Actions Status

A table showing the actions available in this repository:

| Action      | Description                                     |  Status   |
|:------------|:------------------------------------------------|:---------:|
| setup-mdexp | Download and install mdexp from GitHub releases | Available |

## Supported Platforms

The setup-mdexp action supports the following platforms:

| Platform      | Architecture | Tested |
|:--------------|:-------------|:------:|
| ubuntu-latest | x86_64       |  Yes   |
| macos-latest  | arm64        |  Yes   |

## How It Works

The `setup-mdexp` action:

1. Downloads the correct binary for the runner's OS and architecture (prefers compressed archives, falls back to raw binary)
2. Verifies binary integrity via SHA256 digest
3. Verifies build attestation using `gh` CLI
4. Installs the binary to a temporary directory
5. Adds the directory to `PATH` for subsequent steps

See the [setup-mdexp README](../setup-mdexp/README.md) for usage details.
