@echo === files ===

set temp (command mktemp -d)

builtin cd $temp

@test "a directory" -d $temp
@test "a non-existent directory" ! -d $temp.fake
@test "a regular file" (command touch file) -f file
@test "a non-existent regular file" ! -f file.fake
@test "nothing to see here" -z (read <file)

command rm -rf $temp
