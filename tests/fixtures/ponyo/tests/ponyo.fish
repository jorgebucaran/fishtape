@test "functions load from the plugin directory" \
    (functions --details ponyo) = (path resolve (status dirname)/../functions/ponyo.fish)
@test "completions load" (complete --do-complete "ponyo ") = hello
@test "conf.d runs" "$ponyo_conf" = loaded
@test "no Fisher events fire" -z "$ponyo_installed"

emit ponyo_install
@test "Fisher events fire when emitted" "$ponyo_installed" = yes

function written_by_a_test
end

funcsave written_by_a_test >/dev/null
