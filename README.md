# Sled

Sled is the **Seasonal Linear Enigma Device**, a command-line utility for
[Advent of Code][aoc]. It can view your colourful calendar with completion
status, download puzzle explanations and inputs, and submit solutions.

[aoc]: https://adventofcode.com/ "Visit Advent of Code"

## Installation

To install the `sled` CLI utility with [Jeep][]:

[Jeep]: https://github.com/pyrmont/jeep "The Jeep repository on GitHub"

```shell
$ jeep install "https://github.com/pyrmont/sled"
```

## Configuration

Sled requires your Advent of Code session cookie to authenticate with the
Advent of Code server. To get your session cookie:

1. log in to [Advent of Code][aoc]
2. open your browser's developer tools
3. go to the Storage tab
4. find the cookie named `session`
5. copy its value to a file (such as `session.txt`)

## Usage

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

### Downloading Puzzles

Download a puzzle for a specific year and day:

```shell
$ sled puzzle --year 2024 --day 1
```

This downloads both the puzzle explanation and your puzzle input. The puzzle
explanation is converted to Markdown. By default, Sled puts the files for each
day into a subdirectory with a name that matches that day. To save files
without creating any subdirectories, use the `--no-subdirs` option.

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

- the creative ASCII art for that year
- gold stars (`**`) for puzzles you've completed
- full 256-colour support (when available)

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
