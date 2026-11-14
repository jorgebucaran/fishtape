@test "a directory" -d /nonexistent
@test "not equal" ! 1 -eq 1
@test "not a directory" ! -d /
@test "both match" 1 = 1 -a 2 = 3

set --erase name
@test "name is set" -n $name
@test "name is empty" -z $name
@test "one argument" name
