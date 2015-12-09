set -l utilities echo printf pwd

for flag in -t --time
  test "$TESTNAME: benchmark utilities with $flag"
    (fishtape $flag=$utilities | cut -f1 | xargs) = "echo printf pwd"
  end

  test "$TESTNAME: benchmark utilities with $flag and comma separated list"
    (fishtape $flag=(printf "%s\n" $utilities | paste -sd, -) \
      | cut -f1 | xargs) = "echo printf pwd"
  end
end

test "$TESTNAME: pipe benchmark output to program with --pipe"
  (fishtape --time=echo,printf --pipe='cut -f1' \
  | grep -E "echo|printf" | xargs) = "echo printf"
end
