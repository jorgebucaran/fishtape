source $DIRNAME/helpers/select_tap_output.fish

set -l meta (fishtape $DIRNAME/fixtures/meta.fish | select_tap_output)

test "$TESTNAME: display failed test yaml data"
  (printf "%s\n" $meta \
    | sed -n '3,7p' \
    | xargs) = "--- operator: -eq expected: 1 received: 0 ..."
end

test "$TESTNAME: display TAP version"
  (printf "%s\n" $meta | sed -n '1p') = "TAP version $TAP_VERSION"
end

test "$TESTNAME: display 1..count"
  (printf "%s\n" $meta | sed -n '17p') = "1..4"
end

test "$TESTNAME: allow # inline comments" # ok
  (printf "%s\n" $meta | sed -n '14p' | xargs) = "ok 3 inline comments"
end

test "$TESTNAME: ok test"
  (printf "%s\n" $meta | sed -n '15p' | xargs) = "ok 4"
end

test "$TESTNAME: display number of tests"
  (printf "%s\n" $meta | sed -n '18p' | xargs) = "# tests 4"
end

test "$TESTNAME: display number of passed tests"
  (printf "%s\n" $meta | sed -n '19p' | xargs) = "# pass 2"
end

test "$TESTNAME: fail test"
  (printf "%s\n" $meta | sed -n '2p') = "not ok 1 one is zero"
end

test "$TESTNAME: display number of failed tests"
  (printf "%s\n" $meta | sed -n '20p' | xargs) = "# fail 2"
end

test "$TESTNAME: -n argument expects argument"
  (printf "%s\n" $meta \
    | sed -n '8,13p' \
    | xargs) = "not ok 2 nothing is something --- operator: -n expected: a non-zero length string received:  ..."
end

test "$TESTNAME: display program help"
  (fishtape | xargs) = "usage: fishtape [<file> [...]] [--time=<utility[,...]>] [--pipe=<utility>] [--help] [--version] [--dry-run] [--quiet] -t --time=<utility> Benchmark given utility/s -p --pipe=<utility> Pipe line buffered output into utility -d --dry-run Print preprocessed files to stdout -q --quiet Set quiet mode -h --help Show this help -v --version Show version information"
end

test "$TESTNAME: display program version"
  (fishtape -v | cut -f1-2 -d" ") = "fishtape version"
end
