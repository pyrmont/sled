# Changelog

Each release lists what changed since the release before it. The changes made
since the most recent release are under Unreleased.

## Unreleased

- Port Sled from Janet to Wattle. Sled is built from source with Zig and
  Wattle, and the executable includes the runtime. Requests are made by a
  native HTTP module, so `curl` is no longer needed.
- Read the session cookie from `~/.config/sled/session.txt` (or
  `$XDG_CONFIG_HOME/sled/session.txt`) unless `--session` names a file. When
  the file is missing and standard input is a terminal, Sled asks for the
  cookie and saves it, readable only by the user. A `session.txt` in the
  current directory is read only when given with `--session`.
- Add `--version` (`-v`), which prints the version and exits.
- Resolve links in a puzzle that are relative to the puzzle's page, as well as
  those relative to the site.
- Keep line breaks from `<br>` elements in puzzles, which previously raised
  'unrecognised tag :br'.
- Treat a `<` or `>` in a puzzle's text that is not part of a tag as text,
  which previously stopped the parser.
- Drop the FreeBSD release builds.
- Add this changelog. The notes of each GitHub release are its section of
  `CHANGELOG.md`, and the archives of a release include the file.

## 0.1.1 (2025-12-09)

- Add a Homebrew formula for macOS (Apple Silicon) and Linux (x86-64 and
  aarch64).
- Compute the default year and day when Sled runs, rather than when it is
  built.
- Fix the paths inside the release archives, which now extract to a single
  `sled-v<version>` directory.

## 0.1.0 (2025-12-09)

- Initial release, with the `puzzle`, `answer` and `calendar` subcommands.
