test "$TESTNAME: TESTNAME var is defined"
    (set -q TESTNAME) $status -eq 0
end

test "$TESTNAME: DIRNAME var is defined"
    (set -q DIRNAME) $status -eq 0
end

test "$TESTNAME: FILENAME var is defined"
    (set -q FILENAME) $status -eq 0
end

test "$TESTNAME: FILENAME is the path to the running test script"
    -n (printf "%s" "$FILENAME" | grep variables)
end

test "$TESTNAME: DIRNAME is the directory name FILENAME"
    $DIRNAME = (dirname $FILENAME)
end

test "$TESTNAME: TESTNAME is the name of the running script"
    $TESTNAME = variables
end

test "$TESTNAME: DIRNAME is a directory"
    -d $DIRNAME
end

test "$TESTNAME: FILENAME is a file"
    -e $FILENAME
end
