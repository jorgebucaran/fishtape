@test 'a description with # and \ in it' 1 -eq 1
@test lines "$(printf '1\n2')" = 1
@test "indented lines" "$(printf ' 1\n2')" = 1
@test "invisible characters" (printf 'a\tb\e[0m\a') = x
@test "lines with a tab" 1\t\n2 = 1
@test "lines with a final newline" 1\n2\n = 1
