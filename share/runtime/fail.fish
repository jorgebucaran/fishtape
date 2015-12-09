function fail -a msg -d "Generate a failing assertion with a message"
  fishtape_error "$msg" fail success failure
  set __fishtape_count (math $__fishtape_count + 1)
  set __fishtape_fails (math $__fishtape_fails + 1)
end
