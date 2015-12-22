fishtape(1) -- TAP producer and test harness for fish
=====================================================

## SYNOPSIS

`fishtape` [*file* ...]<br>
`fishtape` [`--time`=*utility*[,...]] [`--pipe`=*utility*]<br>
`fishtape` [`--help`] [`--version`]<br>

## DESCRIPTION

*Fishtape* is a TAP (Test Anything Protocol) producer and test harness for fish. Fishtape reads the specified files, or the standard input if no files are given, and executes *test blocks* producing a TAP stream.

This utility also provides a simple mechanism for creating microbenchmarks to measure average utility execution speed.

## OPTIONS

  * `-t`, `--time`=*utility*[,...]:
    Benchmark given <utility> and/or functions.

  * `-p`, `--pipe`=*utility*:
    Pipe line buffered output into given *utility*.

  * `-v`, `--version`:
    Show version information.

  * `-h`, `--help`:
    Show help information.

## EXAMPLES

Test files are fish files with one or more test blocks. A test block consists of an optional description and any test expression supported by `test`(1).

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
        end)
    end

The general syntax is:

    test description
      <expression>
    end

Where *expression* is any `test`(1) valid expression; in addition, `=` and `!=` operators are overloaded to check for item inclusion or exclusion in lists.

    test "this sentence contains the word it"
      it = this sentence contains the word it
    end

## SETUP AND TEARDOWN

  * `setup`:
    Run before each test in the current file. Use `setup` to load fixtures and/or set up your environment.

    ```
    set -l path $DIRNAME/$TESTNAME

    function setup
      mkdir -p $path
    end
    ```

  * `teardown`:
    Run after each test in the current file. Use `teardown` to clean up loaded resources, etc.

    ```
    function -S teardown
      rm -rf $path
    end
    ```

## VARIABLES

The following variables are available inside a test file:

  * `$FILENAME`:
      Path to the running script.

  * `$DIRNAME`:
      Directory name of the running script.

  * `$TEST`:
      Name of the running script.

  * `$TAP_VERSION`:
      TAP protocol version.


## METHODS

The following methods are available inside a test file:

  * `comment` [*message*]:
      Print a message without breaking the tap output. This is a wrapper for `printf "# %s\n" >&2`.

  * `pass` [*message*]:
      Generate a passing assertion with a message.

  * `fail` [*message*]:
      Generate a failing assertion with a message.


## MICROBENCHMARKS

You can measure average execution speed between functions and/or other utilities using `--time`=*function*[,...].

This can be useful when trying to compare two or more ways to do the same thing, and we want to know which one is possibly faster.

```
fishtape --time=func{1,2,3} [--pipe=program]
```

Fishtape will use any available standard input for arguments when invoking each of the given functions:

```
fishtape --time=bubble,heap,qsort < numbers
```


## BUGS

### Line Buffered Output

According to <github.com/fish-shell/fish-shell/issues/1396> redirections and pipes involving blocks are run serially, not in parallel. This causes `fishtape` to block the pipeline and buffer all of its output. To emit a line buffered stream use `--pipe`=*program*.

    fishtape test.fish --pipe=tap-consumer


### Tests

* Only one expression per test block is allowed. Use command substitutions to create more complex test expressions.

* Each test file is wrapped in `begin; end` blocks behind the scenes to protect your local scope. Also, after each test, global variables are restored to their initial value at the time of running `fishtape`.

## AUTHORS

Jorge Bucaran *j@bucaran.me*. See also AUTHORS.

## SEE ALSO

* `test`(1)
* `fishtape`(7)
* `help` expand-command-substitution
* `https://github.com/fisherman/fishtape/issues`

[fishtape-7]: https://github.com/bucaran/fishtape/blob/master/man/man7/fishtape.md
