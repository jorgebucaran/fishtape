@test before 1 -eq 1
command kill -INT $fish_pid
@test after 1 -eq 1
