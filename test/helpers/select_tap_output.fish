function select_tap_output
  # Ignore any non TAP output in the console.
  sed -n '/^TAP version 13$/,$p'
end
