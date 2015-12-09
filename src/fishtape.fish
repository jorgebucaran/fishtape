function fishtape -d "TAP producer and test harness for fish"
  if not set -q argv[1]
    fishtape --help
    return 1
  end

  set -l fishtape_version

  set -l files
  set -l utils
  set -l pipes
  set -l print source
  set -l quiet /dev/stderr

  printf "%s\n" $argv | sed -E 's/(^--?[a-z]+)=?/\1 /' | while read -l 1 2
    switch "$1"
      case -t --time
        if test -z "$2"
          read 2
        end
        set utils $utils $2

      case -p --pipe
        if test -z "$2"
          read 2
        end
        set pipes $pipes $2

      case -q --quiet
        set quiet /dev/null

      case -d --dry-run
        set print cat

      case -v --version
        printf "fishtape version %s\n" $fishtape_version
        return

      case -h --help
        printf "usage: fishtape [<file> [...]] [--time=<utility[,...]>]\n"
        printf "                [--pipe=<utility>] [--help] [--version]\n"
        printf "                [--dry-run] [--quiet]\n\n"

        printf "  -t --time=<utility>  Benchmark given utility/s\n"
        printf "  -p --pipe=<utility>  Pipe line buffered output into utility\n"
        printf "         -d --dry-run  Print preprocessed files to stdout\n"
        printf "           -q --quiet  Set quiet mode\n"
        printf "            -h --help  Show this help\n"
        printf "         -v --version  Show version information\n"
        return

      case -- -
      case -\*
        printf "fishtape: '%s' is not a valid option.\n" $1 >&2
        fishtape --help >&2
        return 1

      case \*
        if test ! -e "$1"
          printf "fishtape: '%s' invalid file name\n" $1 >$quiet
          return 1
        end

        set files $files $1
    end
  end

  switch "$utils"
    case \?\*
      set -l args ""
      if not isatty
        set -l IFS \n
        read -az args
      end

      set -l IFS " ,"
      printf "%s " $utils | read -laz utils

      if not test -z "$pipes"
        fish -c "fish -c \"fishtape --time="(
          printf "%s\n" $utils | paste -sd, -)"\""(printf "|%s" $pipes)

        return
      end

      for util in $utils
        functions -q -- $util
        or command -s -- $util > /dev/null
        or contains -- $util (builtin -n)
        or begin
          printf "fishtape: '$util' is not a function\n" >$quiet
          return 1
        end

        set -l ms -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)'
        set -l laps 10

        if set -q FISHTAPE_LAPS
          set laps $FISHTAPE_LAPS
        end

        set -l $util 0

        for lap in (seq $laps)
          set -l $lap (perl $ms)

          eval $util (printf "\"%s\" " $args) >/dev/null ^&1

          set $lap (math (perl $ms) - $$lap)
          set $util (math $$util + $$lap)
        end

        printf "%-10s\t%s\n" $util (math $$util / $laps | awk '
          /^[0-9]/ {
            split("h:m:s:ms", units, ":")

            for (i = 2; i >= -1; i--) {
              if (t = int(i<0 ? $0%1000 : $0/(60^i*1000)%60)) {
                printf("%s%s ", t, units[sqrt((i - 2)^2) + 1])
              }
            }
            print ""
          }')
      end

    case \*
      if not test -z "$pipes"
        fish "%s\n" "fish -c \"fishtape $files\""(printf "|%s" $pipes)
        return
      end

      awk (
        for name in runtime total locals reset setup count teardown
          printf "%s\n" -v $name=(functions __fishtape@{$name} \
            | sed '1d;$d;s/\\\/\\\\\\\/g' \
            | paste -sd\; -)
        end) '

        # FISHTAPE #

        ' $files | fish -c "$print" ^$quiet
  end
end
