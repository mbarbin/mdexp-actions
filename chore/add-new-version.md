# Chore: Add support for a new mdexp release

A reusable runbook for the recurring chore of picking up a newly published
[mdexp](https://github.com/mbarbin/mdexp) CLI release and wiring it through
this repo (`mdexp-actions`).

## When to use this

Run this whenever a new mdexp release moves from **draft** to **published**
on <https://github.com/mbarbin/mdexp/releases>. A draft is not usable yet:
its release assets aren't at their final public download URLs and
`install.sh` / `gh attestation verify` won't resolve it. Wait for it to be
published before starting Step 0.

## How this differs from `RELEASING.md`

Don't confuse the two:

- **This doc** — adopting a new upstream **mdexp CLI** version: updating the
  digests, the compatibility table, and the CI pins in this repo so that
  `setup-mdexp` can install it and CI tests against it.
- **`RELEASING.md`** — cutting a new tagged **release of this repo**
  (`mdexp-actions` itself), i.e. publishing a new `vX.Y.Z` of the actions.

Bumping mdexp support is usually a reason to eventually cut a new
`mdexp-actions` release, but the two don't have to happen in the same PR.
Land the version bump on `main` first (Steps 0-8 below), then optionally
follow up with `RELEASING.md` if a new tag of this repo is warranted.

## Files involved (source of truth vs. generated vs. hand-pinned)

| File | Kind | Notes |
|---|---|---|
| `README.ml` | **source of truth** | `Compatibility.rows` — the table in the root `README.md`. |
| `setup-mdexp/digests.ml` | **source of truth** | `digests` list — the table in `setup-mdexp/DIGESTS.md`. Tracks `linux-x86_64` only. |
| `README.md` | **generated** | Produced from `README.ml` via `mdexp pp`. Never hand-edit. |
| `setup-mdexp/DIGESTS.md` | **generated** | Produced from `digests.ml` via `mdexp pp`. Never hand-edit. |
| `.github/workflows/build.yml` | hand-pinned | `mdexp-version` + `mdexp-digest` for both `ubuntu-latest` and `macos-latest`. |
| `.github/workflows/ci.yml` | hand-pinned | `test-install.sh` invocation, linux digest only. |
| `.github/workflows/test-setup-mdexp.yml` | hand-pinned | `mdexp-version` in both jobs; the `test-digest-mismatch` job's digest is an intentionally-wrong placeholder — **leave it alone**. |
| `setup-mdexp/README.md` | example only | Usage snippet uses a placeholder version (`0.0.20260403`) — not a real pin, no need to bump. |

The `README.ml` / `digests.ml` files are literate-programming sources: they
embed real `[%expect]`-tested tables inside `@mdexp ... @mdexp.snapshot`
comments (see `test/dune`, `dune`, `setup-mdexp/dune` for the `mdexp pp`
rules). Crucially, `mdexp pp` renders the **static** `[%expect]` block text —
it does not execute the code — so editing the OCaml data alone is not enough;
the expect-test snapshot has to be promoted before the derived `.md` picks it
up (see Step 3).

## Step 0 — Identify the new release and check if there's anything to do

```sh
gh release view <version> --repo mbarbin/mdexp
# or browse https://github.com/mbarbin/mdexp/releases
```

mdexp versions are date-based: `0.0.YYYYMMDD`. Find the currently pinned
version by checking exactly the files listed in the table above (a blind
repo-wide grep for that date pattern also catches unrelated tools pinned the
same way, e.g. `dunolint-version`/`crs-version` in other workflow files —
false positives that don't concern mdexp):

```sh
grep -n "0\.0\.[0-9]\{8\}" \
  README.ml README.md \
  setup-mdexp/digests.ml setup-mdexp/DIGESTS.md \
  .github/workflows/build.yml .github/workflows/ci.yml .github/workflows/test-setup-mdexp.yml
```

**Stop condition:** if every occurrence already matches the new version,
there is nothing to do.

## Step 1 — Compute the SHA256 digest for each platform tested in CI

This repo tests two runners, `ubuntu-latest` (linux-x86_64) and
`macos-latest` (the arch depends on GitHub's current default for that
label — check the actual asset name on the release page, don't assume).
mdexp's `release-artifacts.yml` workflow does **not** publish an aggregate
checksums file, so each digest has to be computed from the real asset,
mirroring exactly what `install.sh` does at runtime: it hashes the
**extracted binary**, not the `.tar.gz`.

```sh
VERSION=<new-version>
tmp=$(mktemp -d) && cd "$tmp"

# Confirm the exact asset names first:
gh release view "$VERSION" --repo mbarbin/mdexp

for TARGET in linux-x86_64 macos-<arch>; do   # use the real suffixes from the command above
  curl -fsSL "https://github.com/mbarbin/mdexp/releases/download/${VERSION}/mdexp-${VERSION}-${TARGET}.tar.gz" -o "${TARGET}.tar.gz"
  mkdir "${TARGET}" && tar -xzf "${TARGET}.tar.gz" -C "${TARGET}"
  sha256sum "${TARGET}/mdexp"
done
```

Record both as `sha256:<hex>` — the `sha256:` prefix is part of the value
used everywhere in this repo (inputs, `DIGESTS.md`, `digests.ml`).

> **Trap:** don't take a shortcut through `gh api repos/mbarbin/mdexp/releases/tags/<version>`
> (or `gh release view --json assets`) and grab each asset's `digest` field.
> That field is the SHA256 of the **`.tar.gz` archive itself**, not the
> binary inside it — a different value from what `install.sh` checks and
> what `mdexp-digest` expects. Always extract the archive and hash the
> binary, as above. (Verified live on the `0.0.20260814` release: the API's
> archive digest and the extracted-binary digest are two different hashes.)

Optionally cross-check the build attestation the same way `install.sh` does:

```sh
gh attestation verify "${TARGET}/mdexp" --repo mbarbin/mdexp
```

## Step 2 — Update the source-of-truth OCaml files

1. `setup-mdexp/digests.ml`: add an entry to `digests` with the new
   `version` and the `linux-x86_64` digest from Step 1 (prepend, newest
   first, keeping older entries — this table is a historical registry of
   every digest ever needed, not just the latest).
2. `README.ml`: update `Compatibility.rows` with a new row for the new CLI
   version (action version it applies to, `✅` status, and a note such as
   `"latest, recommended"`). If keeping the previous row for history, adjust
   its note (e.g. drop `"latest, recommended"`).

## Step 3 — Promote snapshots, then regenerate the derived docs

Two passes are required — pass 1 promotes the `[%expect]` blocks inside
`README.ml` / `digests.ml` to match the data you just edited; pass 2
regenerates `README.md` / `DIGESTS.md` from those now-correct sources:

```sh
opam exec -- dune build @all
opam exec -- dune runtest --auto-promote   # pass 1: promote [%expect] blocks
opam exec -- dune runtest --auto-promote   # pass 2: regenerate README.md / DIGESTS.md
opam exec -- dune runtest                  # must be clean now
```

Check `git diff` — `README.md` and `setup-mdexp/DIGESTS.md` should show the
new row(s), and `README.ml` / `digests.ml` should show matching updated
`[%expect]` blocks.

## Step 4 — Update the CI workflow pins by hand

These are **not** generated — edit them directly:

- `.github/workflows/build.yml` and `.github/workflows/test-setup-mdexp.yml`
  — each matrix entry pairs `mdexp-version` and `mdexp-digest` together
  (both keyed by `os`), and the step reads
  `mdexp-version: ${{ matrix.mdexp-version }}` /
  `mdexp-digest: ${{ matrix.mdexp-digest }}`. Update both fields in every
  entry (linux and macos) — don't leave `mdexp-version` as a bare value
  outside the matrix, since that decouples it from the digest it's actually
  paired with and invites the two drifting out of sync.
- `.github/workflows/ci.yml` — the `test-install.sh` call (version + linux
  digest).
- `.github/workflows/test-setup-mdexp.yml`'s `test-digest-mismatch` job —
  it isn't matrix-paired with a digest (single fixed wrong digest for all
  os), so just bump its plain `mdexp-version` value; leave the
  deliberately-wrong digest untouched.

## Step 5 — Local sanity check against the real release

Before pushing, exercise the installer against the actual new release:

```sh
GH_TOKEN=$(gh auth token) ./setup-mdexp/test-install.sh <new-version> sha256:<linux-digest>
```

`install.sh` unconditionally runs `gh attestation verify` as its last check
(not optional, unlike the cross-check in Step 1) — this needs a `gh` CLI
recent enough to have the `attestation` subcommand (older installs, e.g.
2.46.x, will fail with `unknown command "attestation" for "gh"` even though
the digest itself verified fine). If that happens locally, treat the digest
verification line above it as the meaningful local signal and let the real
CI runners (which stay current) do the attestation check.

## Step 6 — Full check

```sh
make check                            # shellcheck
opam exec -- dune build @all @runtest
```

## Step 7 — Update `CHANGES.md`

This repo accumulates changes under an `## Unreleased` header at the top of
the file; `RELEASING.md`'s release process later turns that header into a
dated version section when a release is actually cut. Add (or extend) it:

```markdown
## Unreleased

### Changed

- Bump tested/recommended mdexp CLI version to `<new-version>` (@<you>).
```

## Step 8 — Open a PR

Per `setup-mdexp/README.md`'s guidance, version bumps should go through
their own PR so CI validates the new version end-to-end — `build.yml` and
`test-setup-mdexp.yml` both exercise the new digest on linux and macos —
before merging to `main`.

If, after merging, a new tagged release of `mdexp-actions` itself is
warranted, follow `RELEASING.md` next.

## Report template

```
mdexp version bump — <date>
  New mdexp release        : <version>   (was <previous>)
  Digests
    linux-x86_64            : sha256:<...>
    macos-<arch>             : sha256:<...>
  Attestation verified      : yes/no
  Files changed              : README.ml, README.md, setup-mdexp/digests.ml,
                                setup-mdexp/DIGESTS.md, .github/workflows/{build,ci,test-setup-mdexp}.yml,
                                CHANGES.md
  Verification               : dune build @all @runtest ✓ ; make check ✓ ; test-install.sh ✓
  PR                         : <link>
```
