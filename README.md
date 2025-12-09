# Sled

[![Latest Release](https://img.shields.io/github/v/release/pyrmont/sled)](https://github.com/pyrmont/sled/releases/latest)
[![Test Status](https://github.com/pyrmont/sled/workflows/test/badge.svg)](https://github.com/pyrmont/sled/actions?query=workflow%3Atest)

Sled is the **Seasonal Linear Enigma Device**, a command-line utility for
[Advent of Code][aoc].

[aoc]: https://adventofcode.com/ "Visit Advent of Code"

You can use it to:

- view your calendar and progress
- download puzzle explanations and inputs
- submit solutions

## Prerequisites

Sled uses the `curl` command-line utility to communicate with the Advent of Code
servers. It must be on the PATH of the user that runs `sled`.

## Building

### Pre-Built

Pre-built binaries of `sled` are available as tarballs via the
[Releases][github-releases] section on GitHub for:

- FreeBSD 14 (x86-64 and aarch64)
- Linux (x86-64 and aarch64)
- macOS (aarch64)

[github-releases]: https://github.com/pyrmont/sled/releases

```console
$ curl -LO https://github.com/pyrmont/sled/releases/latest/download/sled-<version>-<platform>-<arch>.tar.gz
$ tar -xzf sled-<version>-<platform>-<arch>.tar.gz
$ cd sled-<version>
```

### From Source

To build the `sled` binary from source, you need [Janet][janet-hp] installed
on your system. Then you can run:

[janet-hp]: https://janet-lang.org

```console
$ git clone https://github.com/pyrmont/sled
$ cd sled
$ git tag --sort=creatordate
$ git checkout <version>
$ janet -e '(import ./bundle) (bundle/build (table :info (-> (slurp "info.jdn") parse)))'
```

## Installing

Move the `sled` binary somewhere on your PATH and `sled.1` to the appropriate
man page location. For example:

```console
# use sudo or doas depending on the permissions of the target directories
$ sudo cp sled /usr/local/bin/ # or _build/sled if you built from source
$ sudo cp man/man1/sled.1 /usr/local/share/man/man1/
```

## Configuring

Sled requires your Advent of Code session cookie to authenticate with the
Advent of Code servers. To get your session cookie:

1. log in to [Advent of Code][aoc]
2. open your browser's developer tools
3. go to the Storage tab
4. find the cookie named `session`
5. copy its value to a file (such as `session.txt`)

## Using

Run `sled --help` for usage information.

```
Usage: sled [--session <file>] <subcommand> [<args>]

Seasonal Linear Enigma Device, a command-line utility for Advent of Code.

Options:

 -s, --session <file>    A file that contains the session ID for the user's
                         logged in session. (Default: session.txt)
 -h, --help              Show this help message.

Subcommands:

 a, answer       Submit an answer.
 c, calendar     Display the calendar.
 p, puzzle       Download a puzzle.

For more information on each subcommand, type 'sled help <subcommand>'.
```

The command-line arguments are explained in more detail in the man page.

### Downloading Puzzles

Download a puzzle for a specific year and day:

```shell
$ sled puzzle --year 2025 --day 1
```

This downloads both the puzzle explanation and your puzzle input. The puzzle
explanation is converted from HTML to a text-friendly format.

By default, Sled puts the files for each day into a subdirectory with a name
that matches that day (e.g. `./day01/puzzle.txt` and `./day01/input.txt`). To
save files without creating any subdirectories, use the `--no-subdirs` option.

### Submitting Answers

Submit an answer for a specific part:

```shell
$ sled answer --year 2025 --day 1 --part 1 <answer>
```

### Viewing the Calendar

Display your Advent of Code calendar with ASCII art and completion status:

```shell
$ sled calendar --year 2025
```

The calendar displays:

- the ASCII art calendar for that year
- gold stars (`**`) for puzzles you've completed
- ANSI 256 colours

To disable colours:

```shell
$ sled calendar --year 2025 --no-color
```

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/sled/issues

## Licence

Sled is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/sled/blob/master/LICENSE
