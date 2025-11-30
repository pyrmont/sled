# Sled

Sled is the **Seasonal Linear Enigma Device**, a command-line utility for
[Advent of Code][aoc]. It can download puzzle explanations and inputs as well
as submit solutions.

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

Run `sled --help` for usage information:

```
$ sled --help
Usage: sled [--part <part>] [--day <day>] [--year <year>] [--no-subdirs] [--session <file>] [<answer>]

Seasonal Linear Enigma Device, a command-line utility for Advent of Code.

Parameters:

 answer    The answer for the given puzzle.

Options:

 -p, --part <part>       The part of the puzzle. (Default: 1)
 -d, --day <day>         The day of the puzzle.
 -y, --year <year>       The year of the puzzle. (Default: 2025)

 -S, --no-subdirs        Save files without creating subdirectories for each day.
 -s, --session <file>    A file that contains the session ID for the user's logged in session. (Default: session.txt)

 -h, --help              Show this help message.
```

### Downloading Puzzles

Download a puzzle for a specific year and day:

```shell
$ sled --year 2024 --day 1
```

This downloads both the puzzle explanation and your puzzle input. The puzzle
explanation is converted to Markdown. By default, Sled puts the files for each
day into a subdirectory with a name that matches that day. To save files
without creating any subdirectories, use the `--no-subdirs` option.

### Submitting Answers

Submit an answer for a specific part:

```shell
$ sled --year 2025 --day 1 --part 1 <answer>
```

When submitting an answer, `--part` must be either `1` or `2`.

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/sled/issues

## Licence

Sled is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/sled/blob/master/LICENSE
