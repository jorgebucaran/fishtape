@echo === files ===

set temp (command mktemp -d)

builtin cd $temp

@test "a directory" -d $temp
@test "not a directory" ! -d $temp/foo/bar
@test "a regular file" (command touch file) -f file
@test "nothing to see here" -z (read <file)

command rm -rf $temp
