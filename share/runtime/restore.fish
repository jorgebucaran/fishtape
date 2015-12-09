function fishtape_restore_globals
  set --global --name | sed -nE 's/^__fishtape_(.*)/\1 &/p' | while read -l var old_var
    set -g $var $$old_var
  end

  return 0
end
