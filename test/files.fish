@mesg $current_filename

function setup
    set -g tmp_dir (command mktemp -d /tmp/foo.XXXX)
end

function teardown
    command rm -rf $tmp_dir
end

@test "a file" (touch $tmp_dir/file) -e $tmp_dir/file
@test "regular file" (touch $tmp_dir/file) -f $tmp_dir/file
@test "file is empty" (touch $tmp_dir/file) ! -s $tmp_dir/file
@test "file is non-empty" (echo foo > $tmp_dir/file) -s $tmp_dir/file
@test "a directory" -d $tmp_dir
