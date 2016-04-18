set -l items foo bar baz quux
set -l alien norf

for item in $items
    set -l array $array $item

    test "arrays: ( $array ) in ( $items )"
        $array = $items
    end

    # The overloaded `=' yields true when all items on the left
    # exist at least once on the right side.

    if not set -q array[(count $items)]
        test "arrays: ( $items ) != ( $array )"
            $items != $array
        end
    end
end

test "arrays: $alien does not exist in $items"
    $alien != $items
end

test "arrays: list contains sentence"
    "now or never" = a b "now or never" c d
end

test "arrays: list contains multiple sentences"
    "now or never" "just do it" "what's done, is done" = \
    a b "now or never" c d "just do it" e f "what's done, is done" g h
end

test "arrays: list does not contain at least one of the given words"
    word1 word2 != a b c word1 d e f
end
