@mesg $current_filename

@test "current_dirname" -d "$current_dirname"
@test "current_filename" -e "$current_dirname/$current_filename"
