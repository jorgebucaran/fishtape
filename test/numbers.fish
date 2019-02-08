@mesg $filename

@test "equal to" 1 -eq 1
@test "less than" 1 -lt 2
@test "less than or equal to" 2 -le 2
@test "greater that or equal to" 2 -ge 2
@test "greater than" 2 -gt 1
@test "not greater than" ! 1 -gt 2
