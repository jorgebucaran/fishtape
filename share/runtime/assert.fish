function fishtape_assert
  set -l count (count $argv)

  if test $count -le 3
    switch "$argv[1]"
      case -n
        not test -z "$argv[2]"
      case \*
        test $argv
    end
    return
  end

  for operator in = !=
    if contains --index -- $operator $argv
      break
    end
  end | read -l index

  switch "$index"
    case "" 1 $count
      return 1
  end

  for item in $argv[1..(math $index - 1)]
    if not contains -- $item $argv[(math $index + 1)..-1]
      test $argv[$index] = "!="
      return
    end
  end

  test $argv[$index] = "="
end
