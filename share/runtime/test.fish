function fishtape_test -a info
  set -e argv[1]

  if fishtape_assert $argv ^ /dev/null
    printf "ok %s" (math 1 + $__fishtape_count)

    if test -n "$info"
      set info " $info"
    end

    printf "%s\n" $info
    return
  end

  switch "$argv[1]"
    case !
      set nix !
      set -e argv[1]
  end

  switch (count $argv)
    case 0 1
      printf "fail\targv > 1\t$argv"

    case 2
      printf "%s\t" "$nix$argv[1]"

      switch "$nix"
        case !
          set nix "not "
      end

      switch "$argv[1]"
        case -z
          printf "%s\t" "$nix""a zero length string"
        case -n
          printf "%s\t" "$nix""a non-zero length string"
        case -b
          printf "%s\t" "$nix""a block device"
        case -c
          printf "%s\t" "$nix""a character device"
        case -d
          printf "%s\t" "$nix""a directory"
        case -e
          printf "%s\t" "$nix""a file"
        case -f
          printf "%s\t" "$nix""a regular file"
        case -g
          printf "%s\t" "$nix""a file with the set-group-ID bit set"
        case -G
          printf "%s\t" "$nix""a file with same group ID as the current user"
        case -L
          printf "%s\t" "$nix""a symbolic link"
        case -O
          printf "%s\t" "$nix""a file owned by the current user"
        case -p
          printf "%s\t" "$nix""a named pipe"
        case -r
          printf "%s\t" "$nix""a file marked as readable"
        case -s
          printf "%s\t" "$nix""a file size greater than zero"
        case -S
          printf "%s\t" "$nix""a socket"
        case -t
          printf "%s\t" "$nix""a terminal tty file descriptor"
        case -u
          printf "%s\t" "$nix""a file with the set-user-ID bit set"
        case -w
          printf "%s\t" "$nix""a file marked as writable"
        case -x
          printf "%s\t" "$nix""a file marked as executable"
        case \*
          printf "%s\t" "a builtin test operator"
      end

      set -e argv[1]

      if test -z "$argv[1]"
        set argv[1] "\"\""
      end

      printf "%s\n" $argv[1]

    case \*
      set -l expected "$argv[1]"
      set -l operator "$argv[2]"
      set -l received "$argv[3..-1]"

      switch "$operator"
        case = != -{eq,ne,gt,ge,lt,le}
        case \*
          switch "$argv"
            case \*" = "\* \*" != "\*
              for op in = !=
                set operator $op
                if contains -i -- $op $argv
                  break
                end
              end | read -l i

              set expected $argv[1..(math $i-1)]
              set received $argv[(math $i+1)..-1]

            case \*
              set operator "fail"
              set expected "= or !="
              set received "$argv"
          end
      end

      printf "$operator\t$expected\t$received\n"
  end | fishtape_error "$info"
end
