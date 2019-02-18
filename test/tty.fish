@mesg $current_filename

function foobar
    if isatty
        echo atty
    else
        echo notatty
    end
end

@test "is a tty" (foobar) = atty
@test "not a tty" (echo | foobar) = notatty
