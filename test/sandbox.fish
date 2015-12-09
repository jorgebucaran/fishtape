set -l tally 0
set -l proof false

function -S setup
  set proof true
  set tally (math 1 + $tally)
end

function -S teardown
  pass "$TESTNAME: teardown is called after running tests"
end

test "$TESTNAME: setup is called before running tests"
  $proof = true
end

test "$TESTNAME: setup is called once per *every* test"
  $tally -eq 2
end
