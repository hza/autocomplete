# Installation options

The quickest way to install is the install script from the [README](../README.md#installation).
This page covers the script's options and the other ways to set autocomplete up.

Prebuilt binaries are published for macOS (Apple silicon and Intel) and Linux (x86_64, arm64).
You need bash 3.2 (the macOS `/bin/bash`) or any newer bash, or zsh ([zsh](#zsh)).

## Install script options

Set `PREFIX=/usr/local`, `PROFILE=~/.bash_profile`, `ZPROFILE=~/.zprofile` or `VERSION=v0.1.0` for `sh` to change the
defaults (e.g. `... | PREFIX=$HOME/bin sh`). The script verifies the download's SHA-256
checksum. Uninstall with `... | sh -s -- --uninstall` (same `PREFIX`/`PROFILE`/`ZPROFILE`).

## Manual download

Pick the tarball for your system (`darwin-arm64`, `darwin-x86_64`,
`linux-x86_64`, `linux-arm64`; Linux binaries are static and run on any distro):

```sh
t=darwin-arm64
curl -fLO https://github.com/hza/autocomplete/releases/latest/download/autocomplete-$t.tar.gz
mkdir -p ~/.local && tar -xzf autocomplete-$t.tar.gz -C ~/.local   # bin/ + share/autocomplete/
echo 'eval "$(~/.local/bin/autocomplete bash)"' >> ~/.bashrc
```

The binary finds its specs in `../share/autocomplete` next to `bin/`, so keep the two together.

## From source

Requires the Xcode Command Line Tools (`xcode-select --install`) on macOS, or gcc/clang and
make on Linux.

```sh
git clone https://github.com/hza/autocomplete.git
cd autocomplete
make install
```

`make install`:

- installs the binary to `/usr/local/bin/autocomplete`,
- installs the bundled specs to `/usr/local/share/autocomplete/`,
- adds `eval "$(autocomplete bash)"` to `~/.bashrc`, unless it's already there,
- adds `eval "$(autocomplete zsh)"` to `~/.zshrc` when that file exists or your login shell
  is zsh.

Open a new terminal (or run `source ~/.bashrc`) and press TAB after `docker`, `git` or `make`.

> macOS Terminal starts login shells, which read `~/.bash_profile`, not `~/.bashrc`.
> `make install` warns if your `~/.bash_profile` doesn't load `~/.bashrc`; add
> `[ -f ~/.bashrc ] && . ~/.bashrc` to it.

Options:

```sh
make install PREFIX=$HOME/.local          # install without sudo (put ~/.local/bin on PATH first)
make install PROFILE=$HOME/.bash_profile  # use a different startup file
make install ZPROFILE=$HOME/.zprofile     # same for zsh
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

## zsh

The same binary and specs work in zsh. Add this line to `~/.zshrc` (the installers do it
for you when `~/.zshrc` exists or zsh is your login shell):

```sh
eval "$(autocomplete zsh)"           # or: eval "$(autocomplete zsh --scan-man)"
```

It runs `compinit` if your `~/.zshrc` hasn't already, then registers one completion function
for every command with a spec. That replaces zsh's own completion for those commands (git,
docker, …). Re-run the line after adding a spec.

zsh shows descriptions, groups and menus natively, so a few bash-specific tricks are left out.
Long flag lists aren't folded into `--`, `📌` or `🧩` entries. Snippets work as in bash: `@<TAB>` lists them as `@key  -- command`
without changing the line, and `@key<TAB>`
substitutes that command directly, as in bash. A list left from the previous TAB is cleared once a single match is inserted. `$VAR`, `~user` and
`user@host` words use zsh's own completion.

## Uninstalling a source install

```sh
make uninstall          # use the same PREFIX / PROFILE you installed with
```

This removes the binary, the bundled specs, their cache files and the exact `eval` line
from your profile. Your own specs in `~/.config/autocomplete` are left untouched.
