@mesg $current_filename

@test "identical" foo = foo
@test "non-identical" foo != bar
@test "! identical" ! foo = bar
@test "! non-identical" ! foo != foo
@test "non-zero length string" -n foo
@test "zero-length string" -z ""
@test "-z nothing" -z
@test "!-n nothing" ! -n
@test "! non-zero-length string" ! -n ""
@test "! zero-length string" ! -z foo
@test "identical arrays" foo bar baz = foo bar baz
@test "non-identical arrays" foo bar baz != baz bar foo
@test "! identical arrays" ! foo bar baz = baz bar foo
@test "multiline" (
    echo foo
    echo bar
    echo baz
) = (
    echo foo
    echo bar
    echo baz
)
@test "multiline expected" "foo bar baz" = (
    echo foo
    echo bar
    echo baz
)
@test "multiline actual" (
    echo foo
    echo bar
    echo baz
) = "foo bar baz"
