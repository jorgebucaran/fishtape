test "one is zero"
    1 -eq 0
end

test "nothing is something"
    -n ""
end

test "inline comments" # sure
    -z ""
end

test # description is optional
    -z ""
end
