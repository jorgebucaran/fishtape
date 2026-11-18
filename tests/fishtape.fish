source (status dirname)/../functions/fishtape.fish
cd (path resolve (status dirname)/fixtures)

@echo Options

@test "fishtape --help displays the help" (fishtape --help | string match --quiet -- 'Usage: fishtape *') $status -eq 0
@test "fishtape -h is short for --help" "$(fishtape -h)" = "$(fishtape --help)"
@test "fishtape --version displays the version" \
    (fishtape --version | string match --quiet -- 'fishtape, version *.*.*') $status -eq 0
@test "fishtape -v is short for --version" "$(fishtape -v)" = "$(fishtape --version)"
@test "fishtape without files displays the help" "$(fishtape)" = "$(fishtape --help)"

@echo "Writing tests"

@test "matches the README example" "$(fishtape example.fish)" = "\
TAP version 14
ok 1 the ultimate question
ok 2 uppercases a word
not ok 3 runs as root
  ---
    operator: \"=\"
    expected: \"root\"
    actual: \"jb\"
    at: \"$PWD/example.fish:5\"
  ...

1..3
# pass 2
# fail 1"

@test "reports the expression for anything but a comparison" "$(fishtape expressions.fish 2>/dev/null)" = "\
TAP version 14
not ok 1 a directory
  ---
    expression: \"-d /nonexistent\"
    at: \"$PWD/expressions.fish:1\"
  ...
not ok 2 not equal
  ---
    operator: \"! -eq\"
    expected: \"1\"
    actual: \"1\"
    at: \"$PWD/expressions.fish:2\"
  ...
not ok 3 not a directory
  ---
    expression: \"! -d /\"
    at: \"$PWD/expressions.fish:3\"
  ...
not ok 4 both match
  ---
    expression: \"1 = 1 -a 2 = 3\"
    at: \"$PWD/expressions.fish:4\"
  ...
not ok 5 name is set
  ---
    expression: \"-n\"
    at: \"$PWD/expressions.fish:7\"
  ...
ok 6 name is empty
not ok 7 one argument
  ---
    expression: \"name\"
    at: \"$PWD/expressions.fish:9\"
  ...

1..7
# pass 1
# fail 6"

@test "prints @echo as a TAP comment and plain echo as is" "$(fishtape comments.fish)" = "\
TAP version 14
# comments
comments
ok 1 passes

1..1
# pass 1
# ok"

@echo "Running tests"

set output (fishtape shell.fish shell.fish)
@test "runs each test file in a new shell" $status -eq 0

set directories (string match -- /\* $output)
@test "gives each test file its own temporary HOME, TMPDIR and XDG base directories" \
    (path sort --unique $directories | count) -eq 14
@test "removes each test file's temporary directories" -z "$(path filter $directories)"

set output "$(fishtape sigint.fish passing.fish)"
@test "exits with status 130 on Ctrl-C" $status -eq 130
@test "stops the run on Ctrl-C" $output = "\
TAP version 14
ok 1 before"

@test "stops the run on Ctrl-C in a sourced file" "$(fishtape sigint-source.fish passing.fish)" = "\
TAP version 14
ok 1 before"

@test "leaves the working directory and other environment variables as they are" \
    "$(EDITOR=vim fishtape environment.fish)" = "\
TAP version 14
# PWD=$PWD
# EDITOR=vim

1..0
# pass 0
# ok"

set output "$(fishtape passing.fish passing.fish)"
@test "exits with status 0 if all the tests pass" $status -eq 0
@test "numbers tests across test files" $output = "\
TAP version 14
ok 1 one
ok 2 two
ok 3 one
ok 4 two

1..4
# pass 4
# ok"

@test "exits with status 1 if a test fails" (fishtape example.fish >/dev/null) $status -eq 1

set output "$(fishtape passing.fish missing.fish 2>/dev/null)"
@test "exits with status 1 if a test file is missing" $status -eq 1
@test "runs nothing if a test file is missing" -z "$output"

@echo "Testing a plugin"

command cp -R ponyo $TMPDIR

@test "loads the plugin without installing it" "$(fishtape $TMPDIR/ponyo/tests/ponyo.fish)" = "\
TAP version 14
ok 1 functions load from the plugin directory
ok 2 completions load
ok 3 conf.d runs
ok 4 no Fisher events fire
ok 5 Fisher events fire when emitted

1..5
# pass 5
# ok"

@test "keeps saved functions out of the plugin" ! -e $TMPDIR/ponyo/functions/written_by_a_test.fish

@test "loads no plugin for a nested test file" "$(fishtape $TMPDIR/ponyo/tests/nested/nested.fish)" = "\
TAP version 14
ok 1 no plugin loads

1..1
# pass 1
# ok"

@echo Failures

@test "ignores a sourced exit" "$(fishtape source.fish)" = "\
TAP version 14
ok 1 keeps going

1..1
# pass 1
# ok"

@test "ignores a sourced exit in an event handler" "$(fishtape source-event.fish)" = "\
TAP version 14
ok 1 before
ok 2 after

1..2
# pass 2
# ok"

set output "$(fishtape return.fish)"
@test "exits with status 0 if a test file returns early" $status -eq 0
@test "passes a test file that returns early" $output = "\
TAP version 14
ok 1 before

1..1
# pass 1
# ok"

@test "fails a test file that ends with a nonzero status" "$(fishtape status.fish)" = "\
TAP version 14
ok 1 before
not ok 2 status.fish
  ---
    message: \"ended with status 1\"
  ...

1..2
# pass 1
# fail 1"

set output "$(fishtape exit.fish passing.fish)"
@test "exits with status 1 if a test file calls exit" $status -eq 1
@test "fails a test file that calls exit and moves on to the next test file" $output = "\
TAP version 14
ok 1 before
not ok 2 exit.fish
  ---
    message: \"exited with status 0 before the end of the file\"
  ...
ok 3 one
ok 4 two

1..4
# pass 3
# fail 1"

@test "fails a test file that calls exit from an event handler" "$(fishtape exit-event.fish)" = "\
TAP version 14
ok 1 before
not ok 2 exit-event.fish
  ---
    message: \"exited with status 0 before the end of the file\"
  ...

1..2
# pass 1
# fail 1"

@test "fails a test file with a syntax error before running it" "$(fishtape syntax-error.fish 2>/dev/null)" = "\
TAP version 14
not ok 1 syntax-error.fish
  ---
    message: \"exited with status 127 before the end of the file\"
  ...

1..1
# pass 0
# fail 1"

@test "fails a test file that gets killed" "$(fishtape kill.fish)" = "\
TAP version 14
ok 1 before
not ok 2 kill.fish
  ---
    message: \"exited with status 137 before the end of the file\"
  ...

1..2
# pass 1
# fail 1"

@echo Output

@test "escapes descriptions for TAP and values for YAML" "$(fishtape escaping.fish)" = "\
TAP version 14
ok 1 a description with \# and \\\\ in it
not ok 2 lines
  ---
    operator: \"=\"
    expected: \"1\"
    actual: |-
      1
      2
    at: \"$PWD/escaping.fish:2\"
  ...
not ok 3 indented lines
  ---
    operator: \"=\"
    expected: \"1\"
    actual: |2-
       1
      2
    at: \"$PWD/escaping.fish:3\"
  ...
not ok 4 invisible characters
  ---
    operator: \"=\"
    expected: \"x\"
    actual: \"a\tb\e[0m\x07\"
    at: \"$PWD/escaping.fish:4\"
  ...
not ok 5 lines with a tab
  ---
    operator: \"=\"
    expected: \"1\"
    actual: \"1\t\n2\"
    at: \"$PWD/escaping.fish:5\"
  ...
not ok 6 lines with a final newline
  ---
    operator: \"=\"
    expected: \"1\"
    actual: \"1\n2\n\"
    at: \"$PWD/escaping.fish:6\"
  ...

1..6
# pass 1
# fail 5"
