# Building Sonic Lineup for Apple Silicon

A native arm64 build of Sonic Lineup 1.1 from upstream source, packaged as a self-contained, ad hoc signed `Sonic Lineup.app`. Intended for personal use; the bundle is not notarized.

## Prerequisites

- An Apple Silicon Mac with Xcode installed (the full application, not only the command-line tools).
- Homebrew at `/opt/homebrew`.
- The formulae in `Brewfile`: Qt 5, Mercurial and Poly/ML for fetching the libraries, Boost, and pkgconf.

## Recipe

```sh
git clone -b arm64 https://github.com/yrammos/sonic-lineup.git
cd sonic-lineup
brew bundle

export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
./repoint install
git -C svcore apply ../patches/svcore/0001-ringbuffer-member-access.patch
qmake -r sonic-lineup.pro
./build.sh
```

`./repoint install` fetches the two dozen libraries at their pinned revisions; the `git apply` line patches one of them, which the build requires. `./build.sh` compiles everything, runs the four svcore test suites, assembles the bundle, and signs it; its full output goes to `build.log`, and on failure it prints only the first error.

## Verification

```sh
"./Sonic Lineup.app/Contents/MacOS/Sonic Lineup" -v    # prints 1.1
codesign -v --deep --strict "Sonic Lineup.app"
open "Sonic Lineup.app"
```

## Rebuilding

Delete the bundle and run `./build.sh` again; the bundle is regenerated and re-signed at every link. After editing any `.pro` or `.pri` file, rerun `qmake -r sonic-lineup.pro` first.

## Changes to upstream

| Commit | Files | Change |
|---|---|---|
| `a4e8b24` | `Brewfile`, `build.sh` | Homebrew dependencies; a quiet build wrapper. |
| `2c6f1f5` | `repoint-project.json`, `repoint-lock.json` | Libraries fetched from their GitHub mirrors, since the original Mercurial host is offline; `sv-dependency-builds` advanced to a revision carrying arm64 libraries. |
| `a19a47a` | `noconfig.pri`, `capnp-regen.pri` | arm64 target; arm64 headers, libraries, and Cap’n Proto compiler; Homebrew Boost; libmad and single-precision FFTW, which have no arm64 build, dropped; CoreAudio decodes MP3 instead. |
| `bfa5034`, `31634c6` | `.gitignore` | Build outputs and fetched libraries ignored; `patches/` kept visible. |
| `18f4566` | `patches/svcore/0001-ringbuffer-member-access.patch` | A one-line fix in svcore for current Apple clang. |
| `159f823` | `noconfig.pri` | FFTW restricted to double precision, the only variant available for arm64. |
| `fbba0f1` | `build.sh` | Error detection no longer mistakes test output for a failure. |
| `cb2eda3` | `deploy/osx/deploy.sh` | Qt and its Homebrew dependencies bundled with `macdeployqt`; bundle ad hoc signed. |

The svcore fix lives in a separately fetched library and is not part of this repository’s history; hence the `git apply` step in the recipe, to be repeated whenever svcore is fetched afresh.

## Limitations

- The signature is ad hoc. A copy moved to another Mac will be blocked by Gatekeeper until allowed under System Settings › Privacy & Security › Open Anyway.
- Qt 5 was never tested against current macOS SDKs; qmake says so at length, but the warnings are harmless.
