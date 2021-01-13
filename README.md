# Fishtape

> 100% _pure_-[Fish](https://fishshell.com) test runner.

Fishtape is a <a href=https://testanything.org title="Test Anything Protocol">Test Anything Protocol</a> compliant test runner for Fish. Use it to test anything: scripts, functions, plugins without ever leaving your favorite shell. Here's the first example to get you started:

```fish
@test "the ultimate question" (math "6 * 7") -eq 42

@test "got root?" $USER = root
```

Now put that in a `fish` file and run it with `fishtape` installed. Behold, the TAP stream!

```console
$ fishtape example.fish
TAP version 13
ok 1 the ultimate question
not ok 2 got root?
  ---
    operator: =
    expected: root
    actual: jb
    at: ~/example.fish:3
  ...

1..2
# pass 1
# fail 1
```

> See [reporting options](#reporting-options) for alternatives to TAP output.

Each test file runs inside its own shell, so you can modify the global environment without cluttering your session or breaking other tests. If all the tests pass, `fishtape` exits with `0` or `1` otherwise.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install jorgebucaran/fishtape
```

## Writing Tests

Tests are defined with the `@test` function. Each test begins with a description, followed by a typical `test` expression. Refer to the `test` builtin [documentation](https://fishshell.com/docs/current/cmds/test.html) for operators and usage details.

> Operators to combine expressions are not currently supported: `!`, `-a`, `-o`.

```fish
@test "has a config.fish file" -e ~/.config/fish/config.fish
```

Sometimes you need to test the exit status of running one or more commands and for that, you use command substitutions. Just make sure to suppress stdout to avoid cluttering your `test` expression.

```fish
@test "repo is clean" (git diff-index --quiet @) $status -eq 0
```

Often you have work that needs to happen before and after tests run like preparing the environment and cleaning up after you're done. The best way to do this is directly in your test file.

```fish
set temp (mktemp -d)

cd $temp

@test "a regular file" (touch file) -f file
@test "nothing to see here" -z (read < file)

rm -rf $temp
```

When comparing multiline output you usually have two options, collapse newlines using `echo` or collect your input into a single argument with [`string collect`](https://fishshell.com/docs/current/cmds/string-collect.html). It's your call.

```fish
@test "first six evens" (echo (seq 2 2 12)) = "2 4 6 8 10 12"

@test "one two three" (seq 3 | string collect) = "1
2
3"
```

If you want to write to stdout while tests are running, use the `@echo` function. It's equivalent to `echo "# $argv"`, which prints a TAP comment.

```fish
@echo -- strings --
```

## Reporting Options

If you're looking for something fancier than plaintext, [here's a list](https://github.com/sindresorhus/awesome-tap#reporters) of reporters that you can pipe TAP into.

```console
$ fishtape test/* | tnyan
 8   -_-_-_-__,------,
 0   -_-_-_-__|  /\_/\
 0   -_-_-_-_~|_( ^ .^)
     -_-_-_-_ ""  ""
  Pass!
```

## License

[MIT](LICENSE.md)
