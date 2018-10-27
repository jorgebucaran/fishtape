# Fishtape

[![Build Status][travis-badge]][travis-link]

> ✋ Psst! Fishtape is currently being rewritten. Follow [this issue](https://github.com/fisherman/fishtape/issues/31) for updates and check back soon!

Fishtape is a [TAP] producing test runner for [fish]. It scans one or more *.fish* files and evaluates test blocks producing a TAP stream.

## Install

With [fisher]:

```fish
fisher add jorgebucaran/fishtape
```

## Usage

### Writing Tests

Test files are *.fish* files with one or more test blocks. A test block consists of an optional description and any test expression supported by test(1).

```fish
test "current directory is home"
    $HOME = $DIRNAME
end

test "math still works"
    42 -eq (math 41 + 1)
end

test "test is a builtin"
    "test" = (builtin -n)
end

test "no odds are evens"
    1 3 5 7 != (
        for i in (seq $n)
            if test (math $i%2) = 0
                echo $i
            end
        end
        )
end
```

### Running Tests

Fishtape reads any given files, or the standard input if no files are given, and converts test blocks into valid Fish syntax which is then evaluated, producing a TAP stream.

```fish
fishtape path/to/tests/*.fish
```

## Setup and Teardown

Include a setup and teardown method in your test file with code that must be run before and after every test.

### `setup`

Run before each test in the current file. Use setup to load fixtures and/or set up your environment.

```fish
set path $DIRNAME/$TESTNAME

function setup
    mkdir -p $path
end
```

### `teardown`

Run after each test in the current file. Use teardown to clean up loaded resources, etc.

```fish
function teardown
    rm -rf $path
end
```

## Variables

The following variables are available inside a test file:

### `$FILENAME`

Path to the running script.

### `$DIRNAME`

Directory name of the running script.

### `$TESTNAME`

Name of the running script.

### `$TAP_VERSION`

TAP protocol version.

## Notes

### Line Buffered Output

According to [fish-shell/#1396], redirections and pipes involving blocks are run serially, not in parallel. This causes fishtape to block the pipeline and buffer all of its output. To emit a line buffered stream use --pipe=*program*.

```fish
fishtape test.fish --pipe=tap-nyan
```

### Tests

* Only one expression per test block is allowed. Use command substitutions to create complex test expressions.

* Each test file is wrapped in `begin; end` blocks under the hood to protect your local scope. In addition, global and universal variables are restored before each test.

* See [Awesome TAP] for a list of consumers / reporters, tools and other TAP resources.

[travis-link]: https://travis-ci.org/fisherman/fishtape
[travis-badge]: https://img.shields.io/travis/fisherman/fishtape.svg
[slack-link]: https://fisherman-wharf.herokuapp.com/
[slack-badge]: https://fisherman-wharf.herokuapp.com/badge.svg

[TAP]: http://testanything.org/
[fish]: https://github.com/fish-shell/fish-shell
[Awesome TAP]: https://github.com/sindresorhus/awesome-tap
[fisherman]: http://github.com/fisherman/fisherman
[issues]: https://github.com/fisherman/fishtape/issues
[fish-shell/#1396]: https://github.com/fish-shell/fish-shell/issues/1396
