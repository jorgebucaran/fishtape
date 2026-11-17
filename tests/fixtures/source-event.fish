function cleanup --on-event cleanup
    echo exit | source
end

@test before 1 -eq 1
emit cleanup
@test after 1 -eq 1
