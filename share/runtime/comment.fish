function comment -d "Print a message without breaking the TAP output"
  printf "# %s\n" $argv >& 2
end
