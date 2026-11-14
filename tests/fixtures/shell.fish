@test "starts in a new shell" -z "$seen"
set --global seen yes

printf '%s\n' $HOME $TMPDIR $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME $XDG_RUNTIME_DIR
