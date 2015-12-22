fishtape(7) -- An Introduction to Fishtape
==========================================

## WHAT IS TAP?

TAP, the test anything protocol, is a text-based format for communication between unit tests and a test harness. Fishtape is a TAP producer and test harness, it will run tests written in fish and produce a TAP stream. This stream can be piped into a TAP-consumer, for example a TAP reporter.

## WHAT IS FISHTAPE?

*Fishtape* is a TAP producer and test harness for fish. A test harness is responsible for running your test from multiple files and generating a test report. In this case, harness is analogous to framework.

## WRITING TESTS

Test files are fish files with one or more *test blocks*. A test block consists of a description (optional) and a test expression supported by `test`(1).

```
test
  ok = ok
end

test "status check"
  (true) $status -eq 0
end

test "math still works"
  (math 1+1) = 2
end

test "list contains word"
  word = a b word c d
end

test "list contains multiple words"
  word1 word2 word3 = a b word1 c d word2 e f word3 g h
end
```

To run `test.fish`:

```
fishtape path/to/*.fish
```

## EVALUATION

Fishtape reads any number of files, or the standard input if no files are given, and converts test blocks into valid fish syntax which is then evaluated. If you try to `source test.fish` or `fish -c test.fish` fish will throw an error.

Each test block is converted to a single `test` call and only one expression is allowed per block.

The preprocess stage generates valid syntax, adds a small runtime with helper functions and local variables `FILENAME`, `DIRNAME` and `TESTNAME` at the top of the file. See `fishtape`(1).

## SCOPE

Each test file is wrapped in `begin; end` blocks behind the scenes to protect your local scope. Also, after each test, global variables are restored to their initial value at the time of running `fishtape`.

This means you can safely modify global variables during `setup` without affecting other test files.

```
# my_app/tests/sync.fish

function setup
  set -g my_remote file:///remote_mock/.git
end

test "sync app with remote origin"
  0 = (my_app sync; echo $status)
end

# my_app/tests/other.fish

test "remote is a url"
  echo $my_remote | grep '^https://'
end
```

You can still share global variables if you must to, by prepending an underscore "`_`" to the variable name.

```
set -g _secret 42
```

## SEE ALSO

* fishtape(1)
* http://testanything.org/
* https://en.wikipedia.org/wiki/Test_Anything_Protocol
