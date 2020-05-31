# Fishtape [![Releases](https://img.shields.io/github/release/jorgebucaran/fishtape.svg?label=&color=0366d6)](https://github.com/jorgebucaran/fishtape/releases/latest)

> <a href=https://testanything.org title="Test Anything Protocol">TAP</a>-based test runner for the [fish shell](https://fishshell.com).

Because your tests run concurrently in their own sub-shells, you can set variables, define functions, and modify the executing environment without hijacking your current session or other tests. There's not even a learning curve. If you know how to use the [`test`](https://fishshell.com/docs/current/commands.html#test) builtin, you are ready to use Fishtape.

## Installation

With [Fisher](https://github.com/jorgebucaran/fisher) (recommended):

```console
fisher add jorgebucaran/fishtape
```

<details>
<summary>Not using a package manager?</summary>

---

Copy [`fishtape.fish`](fishtape.fish) to any directory on your function path.

```fish
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
curl https://git.io/fishtape.fish --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fishtape.fish
```

To uninstall it, remove `fishtape.fish`.

</details>

### System Requirements

- [fish](https://github.com/fish-shell/fish-shell) 2.0+

## Usage

A test file is a regular `fish` file with `@test` declarations. A test declaration (or test case) consists of a description, followed by one or more operators and their arguments. You can use any operator supported by the [`test`](https://fishshell.com/docs/current/commands.html#test) builtin except for the `-a` and `-o` conditional operators.

```fish
@test "math is real" (math 41 + 1) -eq 42

@test "basename is fish" (
    string split -rm1 / /usr/local/bin/fish
)[-1] = "fish"

@test "test is a builtin" (
    contains -- test (builtin -n)
) $status -eq 0

@test "print a sequence of numbers" (seq 3) = "1 2 3"
```

Run `fishtape` with one or more test files to run your tests.

```sh
fishtape tests/*.fish
```

```diff
TAP version 13
ok 1 math is real
ok 2 basename is fish
ok 3 test is a builtin
ok 4 print a sequence of numbers

1..4
# pass 4
# ok
```

Test files run in the background in a subshell while individual test cases run sequentially. The output is buffered (delivered in batches) until all jobs are complete. If all the tests pass, `fishtape` exits with status `0`—else, it exits with status `1`.

A buffered output means we can't write to stdout or stderr without running into race conditions. To print a TAP message along with a batch of test results, use the `@mesg` declaration.

```fish
@mesg "Brought to you by the friendly interactive shell."
```

### Setup and Teardown

You can define special `setup` and `teardown` functions, which run before and after each test case, respectively. Use them to load fixtures, set up your environment, and clean up when you're done.

```fish
function setup
    set -g tmp (command mktemp -d /tmp/foo.XXXXX)
    command mkdir -p $tmp
end

function teardown
    command rm -rf $tmp
end

@test "directory is empty" -z (
    pushd $tmp
    command ls -1
    popd
)
```

### Special Variables

The following variables are globally available for all test files:

- `$current_dirname` is the directory where the currently running test file is located.
- `$current_filename` is the name and extension of the currently running test file.

## Reporting Options

TAP is a simple text-based protocol for reporting test results. It's easy to parse for machines and still readable for humans. If you are looking for reporting alternatives, see [this list of reporters](https://github.com/substack/tape#pretty-reporters) or try [tap-mocha-reporter](https://github.com/tapjs/tap-mocha-reporter) for an all-in-one solution.

Once you've downloaded a TAP-compliant reporter and put it somewhere in your `$PATH`, pipe `fishtape` to it.

> Redirections and pipes involving blocks are run serially in fish (see [fish-shell/#1396](https://github.com/fish-shell/fish-shell/issues/1396)). This means we must run `fishtape` in a subshell to enable streaming support.

```fish
fish -c "fishtape test/*.fish" | tap-nyan
```

## License

[MIT](LICENSE.md)
