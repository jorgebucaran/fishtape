if test $__fishtape_count -eq 0
  exit 1
end

printf "\n1..%s\n" $__fishtape_count
printf "# tests %s\n" $__fishtape_count
printf "# pass  %s\n" (math $__fishtape_count - $__fishtape_fails)

if test $__fishtape_fails -gt 0
  printf "# fail  %s\n" $__fishtape_fails
  exit 1
end

printf "\n# ok\n"
