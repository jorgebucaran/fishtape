@test "has a config.fish file" -e ~/.config/fish/config.fish

@test "the ultimate question" (math "6 * 7") -eq 42

@test "got root?" $USER = root