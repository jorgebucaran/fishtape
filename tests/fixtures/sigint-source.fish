@test before 1 -eq 1
echo command kill -INT \$fish_pid | source
@test after 1 -eq 1
