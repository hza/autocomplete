# autocomplete: tab completion and command snippets for bash and zsh

**Fast tab completion, plus ready-made command snippets on `@<TAB>`, for the bash that ships
with macOS (`/bin/bash` 3.2), any newer bash, and zsh. One small C binary, no shell scripts, no dependencies.**

It does two things:

- **Tab completion** for the commands you type every day: subcommands, flags with
  descriptions, and live values such as git branches, docker networks and make targets.
- **Snippets**: type a command, then `@<TAB>`, and pick a complete, working command line.
  No more looking up the curl flags for posting JSON or how to make a tarball.

```console
$ git checkout fe<TAB>
$ git checkout feature/login

$ docker run --network <TAB>
bridge   host   none   my_app_default

$ tar @<TAB>
📌 @c  -- tar -czf backup.tar.gz project/              📚 create a gzip archive of a folder
📌 @x  -- tar -xzf backup.tar.gz                       📚 extract a gzip archive here
📌 @t  -- tar -tzf backup.tar.gz                       📚 list the contents without extracting
🔥 @d  -- tar -xzf backup.tar.gz -C /tmp/out           📚 extract into another directory
🔥 @j  -- tar -cJf backup.tar.xz project/              📚 create an xz archive
...
$ tar @x<TAB>
$ tar -xzf backup.tar.gz
```

You don't need Homebrew bash or the `bash-completion` package. Pressing TAB runs no
shell code, and new terminals open as fast as before. zsh works too, with the same specs
([zsh](docs/installation.md#zsh)).

## Installation

macOS (Apple silicon, Intel) and Linux (x86_64, arm64). Works with bash 3.2 or newer, and
zsh. No sudo: installs to `~/.local` and adds `eval "$(autocomplete bash)"` to `~/.bashrc`
(and `eval "$(autocomplete zsh)"` to `~/.zshrc` when you use zsh).

```sh
curl -fsSL https://github.com/hza/autocomplete/releases/latest/download/install.sh | sh
```

or with `wget`:

```sh
wget -qO- https://github.com/hza/autocomplete/releases/latest/download/install.sh | sh
```

Open a new terminal and press TAB after `git`, `docker` or `make`. For manual download,
building from source, install options and uninstalling, see
[Installation options](docs/installation.md).

## Snippets

Most completion tools help you spell a flag you already know. Snippets help when you don't
remember which flags you need. Type `@` right after the command and press TAB: each snippet
is a working command with a short key and a one-line explanation. `@key<TAB>` inserts it,
ready to edit. 📌 marks the most used ones, which are listed first. A plain TAB never shows
snippets, so it keeps completing files, hosts and flags as usual.

About 135 commands have snippets. Highlights:

- **port** (MacPorts): selfupdate, upgrade outdated, leaves, reclaim, reverse dependencies
- **curl**, **wget**: POST JSON or form data, uploads, headers only, redirects, resuming
- **ps**, **lsof**: top CPU/memory processes, who listens on a port, open files of a process
- **find**, **grep**: recently changed files, large files, recursive search with excludes
- **tar**, **zip**, **unzip**, **unrar**, **gzip**, **xz**, **bzip2**: create, extract, list,
  exclude folders, zip without macOS junk, passwords, split archives, `.app` bundles
- **ssh**: port forwarding, jump hosts, SOCKS proxy, remote commands
- **jq**: pretty-print, pick and filter fields, CSV, shell variables
- **brew**: dependency trees, reverse dependencies, leaves, cleanup, Brewfile backup
- **docker**: `run`, `exec`, the `prune` commands, `compose config`
- **kubectl**, **rsync**, **ffmpeg**, **openssl**, **jfr** and many more
- macOS tools: **defaults** (hidden Finder, Dock and screenshot settings), **sips** (resize,
  convert HEIC), **mdfind**, **pbcopy**, **say**, **duti**
- Shell keywords **for**, **while**, **until**, **case**, **if**: practical one-liners
  (`if git <TAB>` still completes git)

Add your own with a `snippets:` list in any spec ([format](docs/writing-specs.md)).

bash-completion, zsh and fish complete flags and values only. Cheat-sheet tools like
[navi](https://github.com/denisidoro/navi) or [tldr](https://tldr.sh) show examples, but in
a separate command, not at the prompt you're already typing on.

## Completion

**Bundled commands** (about 150):

- **Version control and build:** git, gh, make, mvn, gradle, cargo, go, swift, pod, fastlane
- **Languages and packages:** python, pip, pyenv, node, npm, npx, yarn, pnpm, bun, bunx,
  java, jfr, rbenv, asdf, nvm
- **Containers and cloud:** docker, colima, orbctl, kubectl, kubectx, kubens, k9s, helm,
  minikube, kind, terraform, pulumi, ansible, aws, az, gcloud, doctl, flyctl, vercel
- **Databases:** psql, pg_dump, mysql, mysqldump, redis-cli, sqlite3
- **Network:** ssh, scp, curl, wget, rsync, openssl, dig, nc, tcpdump
- **Files and text:** find, grep, rg, sed, awk, diff, patch, jq, bat, fzf, tar, zip, unzip,
  unrar, gzip, xz, bzip2, compress (and their decompressors)
- **Processes:** ps, kill, pkill, killall, lsof, tmux
- **macOS:** port (MacPorts), brew, mas, open, defaults, launchctl, diskutil, pmset,
  networksetup, security, codesign, xcrun, plutil, hdiutil, spctl, xattr, softwareupdate,
  tccutil, scutil, mdutil, mdfind, mdls, osascript, shortcuts, dscl, log, system_profiler,
  ditto, textutil, sips, screencapture, say, afplay, qlmanage, caffeinate, pbcopy, pbpaste,
  duti, profiles, sw_vers, nettop, fs_usage
- **Other:** code (VS Code), claude (Claude Code), ffmpeg, pngquant, jpegtran, man, help, and
  `autocomplete` itself

**Live values** from your environment, for example:

- git: branches, tags, remotes, stashes, changed files, your aliases
- docker: containers, images, networks, volumes
- kubectl: namespaces, contexts, pods, nodes, resource types
- make: targets and variables, with descriptions from `## text` or the comment above each
  target (honors `-C dir` and `-f file`)
- npm, yarn, pnpm, bun, node: `package.json` scripts and dependencies; npx, bunx: binaries
  in `node_modules/.bin`
- mvn: profiles, modules and plugin goals from `pom.xml`
- ssh, scp: hosts from `~/.ssh/config` and `known_hosts` (`scp gr<TAB>` → `grafana:`)
- java: source files that declare `main` (`java <TAB>`); python: modules for `-m`
  (`python3 -m http<TAB>` → `http.server`)
- aws, az, gcloud: profiles, subscriptions, projects, regions, buckets
- gh: pull requests, issues, workflow runs, releases; helm: releases and charts;
  terraform: resources from state
- kill, killall, pkill: running processes; say: voices; open: app names and bundle ids
- duti: file extensions, app bundle ids (also by app name: `duti -s Preview<TAB>`) and every
  UTI known to the system, read live from LaunchServices

**More:**

- Descriptions next to subcommands and flags (`git stash <TAB>` →
  `pop  -- Apply a stash and remove it`).
- Commands with hundreds of flags, like curl and wget, are grouped to fit your screen.
- `sudo`, `env`, `time` and `xargs` complete the command after them
  (`sudo git chec<TAB>` → `checkout`).
- Handles `--flag=value`, `image:tag`, quoted words and file names with spaces.
- Shell aliases complete like the command they wrap (`autocomplete alias kubectl k`).
- Any other command: generate a spec from its man page or `--help` output, or hand Go/cobra
  programs over to their own completion ([details](docs/generated-specs.md)). With
  `autocomplete bash --man`, every command with a man page completes its flags automatically.
- Your own commands: write a small YAML file, no rebuild ([how](docs/adding-commands.md)).

## Commands

| Command | Description |
|---|---|
| `autocomplete bash [--man]` | Print the init script (use with `eval`). `--man` also registers every command in `$PATH` that has a man page and no spec; its flags are read from the man page on first TAB and [cached](docs/cache.md#man-page-specs). |
| `autocomplete zsh [--man]` | Same for zsh: defines one completion function and registers it with `compdef` (loads `compinit` if needed). |
| `autocomplete list [--user] [--paths] [--tsv]` | List commands that have a spec, with descriptions. `--user`: only your specs in `~/.config/autocomplete`. `--paths`: show which spec file is used. `--tsv`: `NAME<TAB>DESCRIPTION` for scripts. Your specs are tagged `[override]`, `[added]` or `[alias -> CMD]`, plus `generated: …` and `update: NEW > OLD` when the shipped spec is newer. |
| `autocomplete manage` | Same as `list --user`. |
| `autocomplete add [--force] [--from cobra\|man\|help] CMD...` | Write `~/.config/autocomplete/CMD.yaml` from the first source that works: cobra, man page, `CMD --help`. |
| `autocomplete edit NAME` | Edit your copy of a spec in `$VISUAL`/`$EDITOR`/`vi`, copying the shipped one first if needed. Validates after saving; an unchanged copy is removed. |
| `autocomplete diff [NAME...]` | `diff -u` of your copies against the shipped specs. Exits 1 if any differ. |
| `autocomplete rm [-f] NAME...` | Delete your spec or alias (asks first unless `-f`); the shipped spec is used again. |
| `autocomplete alias [--force] CMD NAME...` | Complete `NAME` like `CMD`. |
| `autocomplete alias --rm NAME...` / `--list` | Remove or list aliases. |
| `autocomplete check FILE` | Validate a spec and print how it was parsed (as JSON). |

## FAQ

### Why another bash completion tool?

macOS still ships bash 3.2 from 2007, and the usual tools have moved on:

- **bash-completion 2.x** requires bash 4.2 or newer.
- **bash-completion 1.3**, the last version for bash 3.2, is unmaintained and loads every
  completion script at startup, so each new terminal opens slowly.
- The common workaround is `brew install bash` and changing your login shell.

autocomplete is built for the bash you already have. It's tested against Apple's `/bin/bash`
and builds with the Xcode Command Line Tools.

### Why is it fast?

bash-completion is written in bash and sources its scripts into every shell. autocomplete
registers its binary with `complete -C`, so each TAB runs compiled C directly: no bash
functions, `sed`/`awk` pipelines or subshells. Shell startup does only the registration;
specs are read when you press TAB.

### Why C and not Rust?

- **Nothing extra to install.** C builds with the Xcode Command Line Tools that most Macs
  already have. Rust needs `rustup` and a toolchain of about 1 GB just to run `make`.
- **Size.** The whole engine, including its own YAML parser, is a ~95 KB binary with no
  dependencies. A Rust "Hello, world!" release build is already ~300 KB, because Rust's
  standard library is built into every program.
- **Startup time.** The binary starts on every TAB, so a small binary that only uses libc keeps
  each completion fast.

### Is there a Homebrew package?

No. Homebrew has dropped support for Intel Macs, so I don't support it. Use the install script
above or one of the [other options](docs/installation.md).

### Can I add completion for my own command?

Yes. Write `~/.config/autocomplete/<command>.yaml` describing its subcommands, flags and
values. See [Adding your own commands](docs/adding-commands.md).

## Documentation

- [Installation options](docs/installation.md): install script options, manual download,
  building from source, uninstalling
- [Adding your own commands](docs/adding-commands.md): quick start
- [Writing specs](docs/writing-specs.md): spec format, value types, supported YAML, lookup
  order
- [Generating specs](docs/generated-specs.md): `autocomplete add`
- [Cache](docs/cache.md): man page specs, `exec` output and other cached results
- [Troubleshooting](docs/troubleshooting.md): common problems and fixes
- [How it works](docs/how-it-works.md): what happens when you press TAB

## License

MIT. See [LICENSE](LICENSE).
