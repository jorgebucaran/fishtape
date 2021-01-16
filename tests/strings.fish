@echo === strings ===

@test "identical" foo = foo
@test "not identical" foo != bar
@test "non-zero-length" -n foo
@test "zero-length string" -z ""
@test "collapse \n" (echo (seq 1 3)) = "1 2 3"
@test "multiline" (
    command seq 3 | string collect
) = "1
2
3"