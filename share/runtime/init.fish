set -g TAP_VERSION 13
set -g __fishtape_count 0
set -g __fishtape_fails 0

for var  in (set --global --name)
  switch $var
    case _\* version umask status history COLUMNS FISH_VERSION LINES PWD SHLVL
    case \*
      set -g __fishtape_$var $$var
  end
end

printf "TAP version %s\n" $TAP_VERSION
