set -g SHELL foo

function setup
    set -g USER foo
end

function -S teardown
    set -l msg "$TESTNAME: globals are restored before teardown"

    if test $USER != foo
        pass $msg
    else
        fail $msg
    end
end

test "$TESTNAME: globals modified outside `setup` are set only once #1"
    $SHELL = foo
end

test "$TESTNAME: globals modified outside `setup` are set only once #2"
    $SHELL != foo
end

test "$TESTNAME: globals modified inside `setup` are set once per each test"
    $USER = foo
end
