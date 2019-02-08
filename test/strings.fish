@mesg $filename

@test "identical" foo = foo
@test "not identical" foo != bar
@test "not identical" ! foo = bar
@test "not not identical" ! foo != foo
@test "non-zero length string" -n foo
@test "zero-length string" -z ""
@test "not non-zero-length string" ! -n ""
@test "not zero-length string" ! -z foo
