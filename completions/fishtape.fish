for 1 in fishtape
  complete -c $1 -s t -l time -d "Benchmark given utility/s"
  complete -c $1 -s p -l pipe -d "Pipe line buffered output into utility"
  complete -c $1 -s d -l dry-run -d "Print preprocessed files to stdout"
  complete -c $1 -s q -l quiet -d "Set quiet mode"
  complete -c $1 -s h -l help -d "Show help"
  complete -c $1 -s v -l version -d "Show version information"
end
