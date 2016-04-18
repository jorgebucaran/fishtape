source $DIRNAME/helpers/select_tap_output.fish

test "$TESTNAME: print a '#' TAP comment" (
    echo "comment foo 2>&1" | fishtape - | select_tap_output | xargs
    ) = "TAP version $TAP_VERSION # foo"
end

test "$TESTNAME: generate a passing assertion with pass" (
    echo "pass foo" | fishtape - | select_tap_output | xargs
    ) = "TAP version $TAP_VERSION ok 1 foo 1..1 # tests 1 # pass 1 # ok"
end

test "$TESTNAME: generate a failing assertion with fail" (
    echo "fail foo" | fishtape - | select_tap_output | xargs
    ) = "TAP version $TAP_VERSION not ok 1 foo --- operator: fail expected: success received: failure ... 1..1 # tests 1 # pass 0 # fail 1"
end
