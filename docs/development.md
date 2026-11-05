# Development

For maintainers.

## Building from source

```sh
make            # builds ./autocomplete
make clean
```

The code is plain C with no dependencies, in `src/`: `main.c` (subcommands), `complete.c`
(spec walk), `output.c` (candidate list and display), `builtins.c` (files, make, `$PATH`,
`exec` completers), `spec.c` (spec lookup and cache), `yaml.c` (YAML reader and writer),
`manparse.c` (man page reader) and `util.c`. Bundled specs live in `specs/`, grouped into topic subfolders (`vcs/`, `cloud/`, `lang/`, …); specs are found at any depth.

## Releasing

Push a version tag; GitHub Actions ([release.yml](../.github/workflows/release.yml)) does the rest:

```sh
git tag v0.1.0 && git push origin v0.1.0
```

The workflow builds `autocomplete-{darwin-arm64,darwin-x86_64,linux-x86_64,linux-arm64}.tar.gz`
(`make dist TARGET=…`; macOS on `macos-14` with `-arch`, Linux as static musl binaries on
native runners), creates the GitHub Release with the tarballs, `install.sh` and `SHA256SUMS`,
and updates the Homebrew formula in `hza/homebrew-tap` (needs the repository secret
`HOMEBREW_TAP_TOKEN`: a fine-grained token with contents write access to that repo).
Build a tarball locally with `make dist TARGET=darwin-arm64`.
