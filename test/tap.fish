@mesg $current_filename

@test "version" (
    echo '@test -- -z ""' | fishtape | command awk 'NR == 1'
) = "TAP version 13"

@test "passed" (
  echo '@test -- -z ""' | fishtape
) = "TAP version 13 ok 1 --  1..1 # pass 1 # ok"

@test "failed" (
  echo '@test -- ! -z ""' | fishtape | command awk 'END { print }'
) = "# fail 1"

@test "operator" (
  echo '@test -- -n ""' | fishtape | command awk 'gsub(/ *operator: */, "")'
) = "-n"

@test "!operator" (
  echo '@test -- ! -z ""' | fishtape | command awk 'gsub(/ *operator: */, "")'
) = "!-z"

@test "actual" -z (
  echo '@test -- -n ""' | fishtape | command awk 'gsub(/ *actual: */, "")'
)

@test "expected" (
  echo '@test -- -n ""' | fishtape | command awk 'gsub(/ *expected: */, "")'
) = "a non-zero length string"

@test "invalid operator" (
  echo '@test -- foo bar baz' | fishtape | command awk 'gsub(/ *expected: */, "")'
) = "a valid operator"

@test "todo" (
  echo '@test wip' | fishtape | command awk 'END { print }'
) = "# todo 1"

@test "mesg" (
  echo '@mesg hello' | fishtape | command awk 'NR == 2'
) = "# hello"
