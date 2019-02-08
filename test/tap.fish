@mesg $filename

function fishtape_parse
  fishtape | command awk $argv
end

@test "version" (
  echo '@test -z ""' | fishtape_parse 'NR == 1'
) = "TAP version 13"

@test "passed" (
  echo (echo '@test -z ""' | fishtape)
) = "TAP version 13 ok 1   1..1 # pass 1 # ok"

@test "failed" (
  echo '@test ! -z ""' | fishtape_parse 'END { print }'
) = "# fail 1"

@test "operator" (
  echo '@test -n ""' | fishtape_parse 'gsub(/ +operator: /, "")'
) = "-n"

@test "!operator" (
  echo '@test ! -z ""' | fishtape_parse 'gsub(/ +operator: /, "")'
) = "!-z"

@test "actual" -z (
  echo '@test -n ""' | fishtape_parse 'gsub(/ *actual: */, "")'
)

@test "expected" (
  echo '@test -n ""' | fishtape_parse 'gsub(/ *expected: */, "")'
) = "a non-zero length string"

@test "todo" (
  echo '@test wip' | fishtape_parse 'END { print }'
) = "# todo 1"

@test "mesg" (
  echo '@mesg hello' | fishtape_parse 'NR == 2'
) = "# hello"
