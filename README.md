> ###### Psst! Migrating from V1 to V2? Check the [migration guide](https://github.com/jorgebucaran/fishtape/issues/38) and happy upgrading!

# Fishtape

[![Build Status](https://img.shields.io/travis/jorgebucaran/fishtape.svg)](https://travis-ci.org/jorgebucaran/fishtape)
[![Releases](https://img.shields.io/github/release/jorgebucaran/fishtape.svg?label=latest)](https://github.com/jorgebucaran/fishtape/releases)

Fishtape is a <a href=https://testanything.org title="Test Anything Protocol">TAP</a>-based test runner for the [fish shell](https://fishshell.com).

Your tests run concurrently in their own sub-shells, siloing your test environment. That means you are free to set variables, define functions, and modify the executing environment without hijacking your current session or other tests.

There's no learning curve. If you know how to use the [`test`](https://fishshell.com/docs/current/commands.html#test) builtin, you are ready to use Fishtape.

## Installation

With [Fisher](https://github.com/jorgebucaran/fisher) (recommended):

```fish
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

To uninstall, remove the file.

</details>

### System Requirements

- [fish](https://github.com/fish-shell/fish-shell) 2.0+

## Usage

Test files are `.fish` files with `@test` definitions. A test definition (or test case) consists of an optional description, followed by one or more operators and their arguments. You can use any operator supported by the [`test`](https://fishshell.com/docs/current/commands.html#test) builtin except for the `-a` and `-o` conditional operators.

```fish
@test "math works" (math 41 + 1) -eq 42

@test "extract basename" (
    string split -rm1 / /usr/local/bin/fish
)[-1] = "fish"

@test "test is a builtin" (
    contains -- test (builtin -n)
) $status -eq 0
```

Run `fishtape` with one or more test files to run your tests.

```fish
fishtape tests/*.fish
```

```diff
TAP version 13
ok 1 - math works
ok 2 - extract basename
ok 3 - test is a builtin

1..3
# pass 3
# ok
```

Test files run in the background in a sub-shell while individual test cases run sequentially. Test output is buffered (delivered in batches) until all jobs are complete. If all the test cases pass, `fishtape` exits with status `0`—else, it exits with status `1`.

Buffered output means we can't write to stdout or stderr without running into a race condition. To print a TAP message use the special `@mesg` function.

```fish
@mesg "Brought to you by fish—the friendly interactive shell"
```

The message will be delivered in the same batch of test results from a file.

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
    command ls -1 | command awk '{ ++i } END { print i }'
    popd
)
```

### Special Variables

The following variables are globally available for all test files:

- `$filename` the name of the currently running test file

## Reporting Options

TAP is a text-based protocol for reporting test results. It's easy to parse for machines and still readable for humans. But it isn't the end of it. If you are looking for reporting alternatives see [this list of reporters](https://github.com/substack/tape#pretty-reporters) or try [tap-mocha-reporter](https://github.com/tapjs/tap-mocha-reporter) for an all-in-one solution.

Once you've downloaded a TAP-compliant reporter and put it somewhere in your \$PATH, pipe the output from `fishtape` to it.

> ✋ Redirections and pipes involving blocks are run serially in fish (see [fish-shell/#1396](https://github.com/fish-shell/fish-shell/issues/1396)). This means we must run `fishtape` in a subshell to enable streaming support.

```fish
fish -c "fishtape test/*.fish" | tap-nyan
```

## License

[MIT](LICENSE.md)
