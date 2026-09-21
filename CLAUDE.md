# Sonic Lineup: native arm64 macOS build

## Goal

Produce a self-contained, ad hoc signed `Sonic Lineup.app` for Apple Silicon
from upstream source (last commit Aug 2020; qmake, Qt 5, C++14). One-off
build for personal use. No notarization, no Qt6 port, no meson migration.

## Hard constraints

- No `sudo`. No `make install`. No writes outside this directory, except
  the single Qt mkspec patch described under Known obstacles (ask first).
- Install packages only by editing `Brewfile` and running `brew bundle`.
  Ask before adding a formula.
- Homebrew prefix is `/opt/homebrew`; never assume `/usr/local`.
- Work on branch `arm64`. One logical change per commit, Conventional
  Commits format. Upstream files are patched minimally; no reformatting,
  no drive-by cleanups.
- Push only to `origin` (the fork), branch `arm64`. Never push to
  `upstream`; never open pull requests.
- Never run `make` directly. Build with `./build.sh [make args]`, which
  logs to `build.log` and prints only the first error. Fix that error,
  rebuild, repeat. Do not read `build.log` wholesale; query it with
  `rg -n 'pattern' build.log` or `sed -n 'A,Bp' build.log`. Ignore
  warnings unless they explain an error. Apply the same discipline to
  `./repoint install` and `qmake -r`: redirect to a log, inspect the tail.
- Commit whenever a subproject finishes compiling (order: base, tests,
  checker, server, plugins, app), so the git log carries the state
  across `/clear`.
- Subrepos fetched by `repoint` are separate checkouts (mostly Mercurial).
  Record every change made inside one as a patch file under `patches/`
  (`patches/<subrepo>/NNNN-description.patch`), since those changes are
  not tracked by this git repo.
- Stop and report at the end of each phase. Do not start the next phase
  unprompted.

## Build outline (upstream's macOS path)

```sh
export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
./repoint install  > repoint.log 2>&1; tail -n 20 repoint.log
qmake -r sonic-lineup.pro > qmake.log 2>&1; tail -n 20 qmake.log
./build.sh                     # wraps make; see Hard constraints
```

`noconfig.pri` (the `macx*` block) governs include paths, lib paths, and
defines on macOS; `./configure` is Linux-only.

## Known obstacles

1. **Dependency libs.** `noconfig.pri` points at
   `sv-dependency-builds/osx/{include,lib}` (x86_64). Upstream head of
   `sv-dependency-builds` ships `osx/{include-arm64,lib-arm64,bin-arm64}`,
   but the pin in `repoint-lock.json` predates them. Update that one
   subrepo to head. `lib-arm64` lacks `libfftw3f.a` and `libmad.a`:
   prefer dropping `HAVE_FFTW3F`/`-lfftw3f` and `HAVE_MAD`/`-lmad`
   (vDSP and CoreAudio cover both) over adding formulae.
2. **Cap'n Proto.** Source targets 0.6.x. Use the capnp headers, libs,
   and `capnp` binary from `sv-dependency-builds/osx/*-arm64` as a
   matched set. Do not use Homebrew's capnp (1.x needs C++20). Regenerate
   piper sources via `capnp-regen.pri` only if the versions disagree.
3. **Qt 5 vs. current SDK.** Qt 5's mkspecs may reference the AGL
   framework, absent from recent macOS SDKs; symptom is
   `framework not found AGL` at link. Fix: remove the AGL reference in
   `/opt/homebrew/opt/qt@5/mkspecs/common/mac.conf`. Ask before editing;
   record the diff in `patches/qt5/`.
4. **Subrepo hosts.** If `code.soundsoftware.ac.uk` or `hg.sr.ht` fails,
   find the GitHub mirror (`sonic-visualiser/*`, `cannam/*`,
   `breakfastquay/*`, `c4dm/*`, `piper-audio/*`) and check out the commit
   matching the pinned revision. Report substitutions.
5. **Compiler drift.** Expect a few errors from current Apple clang and
   libc++ (removed legacy `std::` items, missing includes). Fix minimally.
6. **LTO.** If linking static libs with `-flto` fails, remove `-flto`
   from the `macx*` block.
7. **Arch.** Set `QMAKE_APPLE_DEVICE_ARCHS = arm64` in the `macx*` block.
8. **Signing.** `deploy/osx/paths.sh` runs `install_name_tool`, which
   invalidates signatures. Finish with
   `codesign --force --deep -s - "Sonic Lineup.app"`.

## Phases

1. **Fetch.** `./repoint install`; resolve host failures; move
   `sv-dependency-builds` to head. Report: subrepo table (name, host,
   revision, substituted?), `lipo -archs` of every `.a` in `lib-arm64`,
   capnp version in `include-arm64`.
2. **Configure.** Patch `noconfig.pri`; run `qmake -r`. Report the diff.
3. **Compile.** `./build.sh`; fix errors iteratively, first error first. The four `test-svcore-*`
   targets run during the build: report their results, do not disable
   them without asking.
4. **Verify.** `file`/`lipo -archs` on the app binary, the six plugin
   `.dylib`s (azi, match-vamp-plugin, nnls-chroma, pyin, qm-vamp-plugins,
   tuning-difference), `vamp-plugin-load-checker`, and the piper server
   helper. All must be arm64 only. Run the app binary with `-v`.
5. **Bundle.** `deploy/osx/deploy.sh "Sonic Lineup"` (adapt its Qt paths
   to `/opt/homebrew/opt/qt@5`; fall back to `macdeployqt` if simpler),
   then re-sign. Check `otool -L` shows no `/opt/homebrew` paths left
   inside the bundle.
6. **Document.** Write `BUILD-arm64.md`: prerequisites, exact commands,
   the patch list. Addressed to a human reader.
