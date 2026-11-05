# Installation options

The quickest way to install is the install script from the [README](../README.md#installation).
This page covers the script's options and the other ways to set autocomplete up.

Prebuilt binaries are published for macOS (Apple silicon and Intel) and Linux (x86_64, arm64).
You need bash 3.2 (the macOS `/bin/bash`) or any newer bash.

## Install script options

Set `PREFIX=/usr/local`, `PROFILE=~/.bash_profile` or `VERSION=v0.1.0` for `sh` to change the
defaults (e.g. `... | PREFIX=$HOME/bin sh`). The script verifies the download's SHA-256
checksum. Uninstall with `... | sh -s -- --uninstall` (same `PREFIX`/`PROFILE`).

## Homebrew

macOS and Linux:

```sh
brew install hza/tap/autocomplete
echo 'eval "$(autocomplete bash)"' >> ~/.bashrc
```

## Manual download

Pick the tarball for your system (`darwin-arm64`, `darwin-x86_64`,
`linux-x86_64`, `linux-arm64`; Linux binaries are static and run on any distro):

```sh
t=darwin-arm64
curl -fLO https://github.com/hza/bash-autocomplete/releases/latest/download/autocomplete-$t.tar.gz
mkdir -p ~/.local && tar -xzf autocomplete-$t.tar.gz -C ~/.local   # bin/ + share/autocomplete/
echo 'eval "$(~/.local/bin/autocomplete bash)"' >> ~/.bashrc
```

The binary finds its specs in `../share/autocomplete` next to `bin/`, so keep the two together.

## From source

```sh
git clone https://github.com/hza/bash-autocomplete.git autocomplete
cd autocomplete
make install
```

`make install`:

- installs the binary to `/usr/local/bin/autocomplete`,
- installs the bundled specs to `/usr/local/share/autocomplete/`,
- adds `eval "$(autocomplete bash)"` to `~/.bashrc`, unless it's already there.

Open a new terminal (or run `source ~/.bashrc`) and press TAB after `docker`, `git` or `make`.

> macOS Terminal starts login shells, which read `~/.bash_profile`, not `~/.bashrc`.
> `make install` warns if your `~/.bash_profile` doesn't load `~/.bashrc`; add
> `[ -f ~/.bashrc ] && . ~/.bashrc` to it.

Options:

```sh
make install PREFIX=$HOME/.local          # install without sudo (put ~/.local/bin on PATH first)
make install PROFILE=$HOME/.bash_profile  # use a different startup file
```

If `/usr/local` isn't writable, use `sudo make install`.

## Using it without installing

```sh
make
eval "$(./autocomplete bash)"                     # recommended
source /dev/stdin <<<"$(./autocomplete bash)"     # if you prefer `source`
```

> `source <(autocomplete bash)` does **not** work in bash 3.2. A long-standing bash bug
> makes it silently read nothing. Use one of the forms above.

## Uninstalling a source install

```sh
make uninstall          # use the same PREFIX / PROFILE you installed with
```

This removes the binary, the bundled specs, their cache files and the exact `eval` line
from your profile. Your own specs in `~/.config/autocomplete` are left untouched.
