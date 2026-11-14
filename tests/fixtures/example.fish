@test "the ultimate question" (math "6 * 7") -eq 42

@test "uppercases a word" (string upper fish) = FISH

USER=jb @test "runs as root" $USER = root
