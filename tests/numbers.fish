@echo === numbers ===

@test "numerically equal" 1 -eq 1
@test "not numerically equal" 0 -ne 1
@test "greater than" 2 -gt 1
@test "greater than or equal" 2 -ge 2
@test "less than" 1 -lt 2
@test "less than or equal" 2 -le 2
