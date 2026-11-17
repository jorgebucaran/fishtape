function cleanup --on-event cleanup
    exit
end

@test before 1 -eq 1
emit cleanup
