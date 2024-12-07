# Advent of Code 2024

## Requirements

- Zig 0.13.0 (might work with newer versions, but not tested)
- Place your puzzle inputs in `src/inputs/` with the format `day_<day>.txt` (e.g. `day_1.txt`).

Inputs are not provided in this repository, in order to follow [Advent of Code's rules](https://adventofcode.com/about).

## Building

```sh
zig build
```

## Running

```sh
zig build run -- <day>

# Run in release mode (some code is very sub-optimal, so this is recommended)
zig build run --release=safe -- <day>

# Example
zig build run -- 1
zig build run --release=safe -- 11
```
