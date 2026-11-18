# Fishtape

> A test runner for [Fish](https://fishshell.com), the friendly interactive shell.

Fishtape tests your Fish scripts, functions and plugins without ever leaving your favorite shell. Each test checks an ordinary [`test`](https://fishshell.com/docs/current/cmds/test.html) expression, the kind you already write in `if` conditions. There's no assertion language to learn.

- Prints readable results as tests run, in standard [TAP](https://testanything.org)
- Runs tests against a temporary configuration, not yours
- Tests your latest edits without reinstalling the plugin

## Installation

Fishtape needs Fish 3.5 or newer. Install it with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install jorgebucaran/fishtape
```

## Writing tests

Write a test as `@test`, a description and a `test` expression.

```fish
@test "the ultimate question" (math "6 * 7") -eq 42

@test "uppercases a word" (string upper fish) = FISH

@test "runs as root" $USER = root
```

Save them in `tests/example.fish` and run it with `fishtape`.

```console
$ fishtape tests/example.fish
TAP version 14
ok 1 the ultimate question
ok 2 uppercases a word
not ok 3 runs as root
  ---
    operator: "="
    expected: "root"
    actual: "jb"
    at: "/home/jb/project/tests/example.fish:5"
  ...

1..3
# pass 2
# fail 1
```

Fishtape reports the left side of a comparison as `actual` and the right side as `expected`. Write `$USER = root`, not `root = $USER`.

### Checking exit status

To test whether a command succeeds, run it in a command substitution and compare `$status`. Keep the command quiet, or its output becomes part of the expression.

```fish
@test "repo is clean" (git diff-index --quiet @) $status -eq 0
```

### Comparing output

Wrap a command in `"$(...)"` to compare its whole output as one string, even when it's empty or spans several lines. To include standard error, redirect it inside the substitution: `"$(cmd 2>&1)"`.

```fish
@test "counts to three" "$(seq 3)" = "1
2
3"

@test "prints nothing" -z "$(true)"
```

### Printing comments

Print messages with `@echo`, not `echo`. `@echo` writes them as TAP comments, while plain `echo` output isn't valid TAP.

```fish
@echo string tests
```

## Running tests

Fishtape runs test files one at a time, each in a new shell with temporary `HOME`, `TMPDIR` and XDG base directories. The shell doesn't load your configuration or installed plugins. Your working directory and other environment variables, like `PATH`, stay as they are.

Fishtape removes each test file's temporary directories after the file runs, so tests can write to `$HOME` or `$TMPDIR` without cluttering your system.

```fish
cd $TMPDIR

git init --quiet --initial-branch=main

@test "shows the branch" "$(fish_git_prompt)" = " (main)"
```

Anything tests write anywhere else, such as your working directory, is yours to remove.

If all the tests pass, `fishtape` exits with status 0. If there are any failures, `fishtape` exits with status 1. If a test file is missing, nothing runs and `fishtape` exits with status 1.

## Testing a plugin

Put the tests in your plugin's `tests` directory:

```text
ponyo
├── completions
│   └── ponyo.fish
├── conf.d
│   └── ponyo.fish
├── functions
│   └── ponyo.fish
└── tests
    └── ponyo.fish
```

Then run them with `fishtape` from anywhere:

```console
fishtape ~/ponyo/tests/*.fish
```

Before each test file runs, Fishtape adds your plugin's `functions` and `completions` directories to Fish's search paths and sources the files in its `conf.d`. Fishtape doesn't install the plugin, so Fisher's [events](https://github.com/jorgebucaran/fisher#event-system) don't fire. Emit the ones you need at the top of your test file:

```fish
emit ponyo_install
```

## Failures

A test file fails when it has a syntax error, calls `exit`, gets killed or ends with a nonzero status. Fishtape reports it as a failed test and moves on to the next file.

```console
not ok 4 tests/ponyo.fish
  ---
    message: "exited with status 1 before the end of the file"
  ...
```

To end a test file early, use `return` instead of `exit`.

```fish
command --query kubectl || return 0
```

## Output

Fishtape prints [TAP version 14](https://testanything.org/tap-version-14-specification.html). Read the output as it is, or pipe it into a [TAP reporter](https://github.com/sindresorhus/awesome-tap#reporters).

```console
fishtape tests/*.fish | tap-arc
```

## License

[MIT](LICENSE.md)
