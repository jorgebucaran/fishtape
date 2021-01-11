@echo === status ===

@test "default" $status -eq 0
@test "true" (true) $status -eq 0
@test "false" (false) $status -eq 1
@test "pipestatus" (true | false | true) "$pipestatus" = "0 1 0"
@test 255 (fish --command "exit 255") $status -eq 255

set --query do_fail[1] && @test fail 1 -eq 0
