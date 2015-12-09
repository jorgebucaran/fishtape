function fishtape_error -a info operator expected received
  switch 1
    case (count $argv)
      set -l IFS \t
      read operator expected received
  end

  printf "not ok %s" (math 1 + $__fishtape_count)

  if test -n "$info"
    set info " $info"
  end

  printf "%s\n" $info

  echo "  ---"
  echo "    operator: $operator"
  echo "    expected: $expected"
  echo "    received: $received"
  echo "  ..."

  return 1
end
