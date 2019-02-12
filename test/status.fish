@mesg $current_filename

@test "true" (true) $status -eq 0
@test "false" (false) $status -eq 1
@test "return 2" (
    function foo
        return 2
    end
    foo
) $status -eq 2
false
@test "default status" $status -eq 0
