@echo === tap ===

set temp (command mktemp -d)
set tap (
  do_fail=true HOME=$temp fish \
    --init-command=(functions fishtape | string collect) \
    --command="fishtape test/status.fish"
)

@test "tap" $tap[4] = "ok 2 true"
@test "tap" $tap[8] = "not ok 6 fail"
@test "tap" $tap[9] = "  ---"
@test "tap" $tap[10] = "    operator: -eq"
@test "tap" $tap[11] = "    expected: 0"
@test "tap" $tap[12] = "    actual: 1"
@test "tap" $tap[14] = "  ..."
@test "tap" $tap[16] = "1..6"
@test "tap" $tap[17] = "# pass 5"
@test "tap" "$tap[18]" = "# fail 1"

command rm -rf $temp
