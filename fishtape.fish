function fishtape -d "TAP producer and test harness for fish"
    if test -z "$argv"
        fishtape -h
        return 1
    end

    set -l fishtape_version 1.1.0

    set -l files
    set -l pipes
    set -l print source
    set -l error /dev/stderr

    printf "%s\n" $argv | sed -E 's/(^--?[a-z]+)=?/\1 /' | while read -l 1 2
        switch "$1"
            case --pipe
                if test -z "$2"
                    read 2
                end

                set pipes $pipes $2

            case -q --quiet
                set error /dev/null

            case -n -d --dry-run
                set print cat

            case -v --version
                printf "fishtape v%s\n" $fishtape_version
                return

            case -h --help
                __fishtape_usage > /dev/stderr
                return

            case -- -

            case -\*
                printf "fishtape: '%s' is not a valid option.\n" $1 > /dev/stderr
                fishtape -h > /dev/stderr
                return 1

            case \*
                if test ! -e "$1"
                    printf "fishtape: '%s' is not a valid file name\n" $1 > $error
                    return 1
                end

                set files $files $1
        end
    end

    if test ! -z "$pipes"
        fish -c "fish -c \"fishtape $files\""(printf " |%s" $pipes)

        return
    end

    awk (
        for name in runtime total locals reset setup count teardown
          printf "%s\n" -v $name=(functions __fishtape@{$name} | awk '/^#/ { next } { print }' | sed '1d;$d;s/\\\/\\\\\\\/g' | paste -sd ';' -)
        end
        ) '

            BEGIN {
                print runtime
            }

            END {
                # Close last begin block. Handles one-file-only cases too.

                printf("end\n")
                print total
            }

            FNR == 1 {
                if (NR > 1) {

                    # Runs n times per n+1 files.
                    # Close matching begin block corresponding to previous file.
                    # This means each file has private scope for local variables.

                    once = 0
                    printf("end\n")
                }

                printf("begin\n")
                printf("set -l FILENAME %s/%s\n", ENVIRON["PWD"], FILENAME)

                print locals

                if (!once++) {
                    print reset
                }
            }

            /^ *#|^ *$/ { next }

            /^ *test */ {
                  print setup

                  indent = index($0, "test")

                  $1 = ""

                  # Remove inline comments, but allow `#` inside strings.

                  sub("#[^\"]*$", "")

                printf("fishtape_test ")

                if ($0 == "" || $0 == " ") {
                    printf " \"\" "
                }

                printf("%s", $0)

                test++
                next
            }

            test && /^ *end$/ && (indent == index($0, "end")) {

                # A single test block consists of a pair of test/end keywords
                # with matching indentation. Allows you to write tests inside
                # fish loops, conditionals, etc.

                test = 0

                printf("\n")
                print count

                printf("fishtape_restore_globals\n")
                print teardown

                next
            }

            { print }

    ' $files | fish -c "$print" 2>$error
end

function __fishtape_usage
    echo "Usage: fishtape [FILE ...] [(-d | --dry-run)] [--pipe COMMAND]"
    echo "                [(-q | --quiet)] [(-h | --help)] [(-v | --version)]"
    echo
end

function __fishtape@runtime
    function fishtape_assert
        set -l count (count $argv)

        if test $count -le 3
            switch "$argv[1]"
                case -n
                    not test -z "$argv[2]"
                case \*
                    test $argv
            end
            return
        end

        for operator in = !=
            if contains --index -- $operator $argv
                break
            end
        end | read -l index

        switch "$index"
            case "" 1 $count
                return 1
        end

        for item in $argv[1..(math $index - 1)]
            if not contains -- $item $argv[(math $index + 1)..-1]
                test $argv[$index] = "!="
                return
            end
        end

        test $argv[$index] = "="
    end

    function fishtape_cleanup
        set --name | grep __fishtape | while read -l var
            set -e $var
        end

        return 0
    end

    function comment -d "Print a message without breaking the TAP output"
        printf "# %s\n" $argv > /dev/stderr
    end

    function fishtape_error -a info operator expected received
        switch 1
            case (count $argv)
                set -l IFS \t
                read operator expected received
        end

        printf "not ok %s" (math 1 + $__fishtape_count)

        if test -n "$info"
            set info " $info"
        end

        printf "%s\n" $info

        echo "  ---"
        echo "    operator: $operator"
        echo "    expected: $expected"
        echo "    received: $received"
        echo "  ..."

        return 1
    end

    function fail -a msg -d "Generate a failing assertion with a message"
        fishtape_error "$msg" fail success failure
        set __fishtape_count (math $__fishtape_count + 1)
        set __fishtape_fails (math $__fishtape_fails + 1)
    end

    set -g TAP_VERSION 13
    set -g __fishtape_count 0
    set -g __fishtape_fails 0

    for scope in --global --universal
        for var in (set $scope --name)
            switch $var
                case _\* version umask status history COLUMNS FISH_VERSION LINES PWD SHLVL PATH TMUX TERM
                case \*
                    set $scope __fishtape_$var $$var
            end
        end
    end

    printf "TAP version %s\n" $TAP_VERSION

    function pass -a msg -d "Generate a passing assertion with a message"
        fishtape_test "$msg" -z ""
        set __fishtape_count (math $__fishtape_count + 1)
    end

    function fishtape_restore_globals
        for scope in --global --universal
            set $scope --name | sed -nE 's/^__fishtape_(.*)/\1 &/p' | while read -l var old_var
                set $scope $var $$old_var
            end
        end

        return 0
    end

    function fishtape_test -a info
        set -e argv[1]

        if fishtape_assert $argv 2>/dev/null
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

        switch "$argv[1]"
            case -{z,n,b,c,d,e,f,g,G,L,O,p,r,s,S,t,u,w,x}
                printf "%s\t" "$nix$argv[1]"

                if test "$nix" = !
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

                end

                set -e argv[1]

                if test -z "$argv[1]"
                    set argv[1] "\"\""
                end

                printf "%s\n" $argv[1]

            case \*
                switch (count $argv)
                    case 0 1
                        printf "fail\targv > 1\t$argv"

                    case \*
                        if not set -q argv[3]
                            set argv[3] ""
                        end

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

                        printf "$operator\t"(printf "'%s' " $expected)"\t"(printf "'%s' " $received)"\n"
                end
        end | fishtape_error "$info"
    end
end

function __fishtape@count
    or set __fishtape_fails (math $__fishtape_fails + 1)
    set __fishtape_count (math $__fishtape_count + 1)
end

function __fishtape@locals
    set -l TESTNAME (basename $FILENAME .fish)
    set -l DIRNAME (dirname $FILENAME)
end

function __fishtape@reset
    function setup -d "Run before all tests in the current block"
    end

    function teardown -d "Run after all tests in the current block"
    end
end

function __fishtape@setup
    if not setup
        fishtape_error "setup fail" status 0 $status
        fishtape_cleanup
        exit 1
    end
end

function __fishtape@teardown
    if not teardown
        fishtape_error "teardown fail" status 0 $status
        fishtape_cleanup
        exit 1
    end
end

function __fishtape@total
    if test $__fishtape_count -eq 0
        fishtape_cleanup
        exit 1
    end

    printf "\n1..%s\n" $__fishtape_count
    printf "# tests %s\n" $__fishtape_count
    printf "# pass  %s\n" (math $__fishtape_count - $__fishtape_fails)

    if test $__fishtape_fails -gt 0
        printf "# fail  %s\n" $__fishtape_fails
        fishtape_cleanup
        exit 1
    end

    fishtape_cleanup
    printf "\n# ok\n"
end
