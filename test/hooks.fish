@mesg $current_filename

set -g global_counter 1

function setup
    set global_counter (math $global_counter + 1)
end

function teardown
    set global_counter 3
end

@test "setup" $global_counter -eq 2
@test "teardown" $global_counter -eq 4
