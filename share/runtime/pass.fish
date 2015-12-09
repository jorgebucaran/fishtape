function pass -a msg -d "Generate a passing assertion with a message"
  fishtape_test "$msg" -z ""
  set __fishtape_count (math $__fishtape_count + 1)
end
