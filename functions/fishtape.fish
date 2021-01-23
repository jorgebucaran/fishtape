function fishtape --description "Test scripts, functions, and plugins in Fish"
    switch "$argv"
        case -v --version
            echo "fishtape, version 3.0.1"
        case "" -h --help
            echo "Usage: fishtape <files ...>  Run test files"
            echo "Options:"
            echo "       -v or --version  Print version"
            echo "       -h or --help     Print this help message"
        case \*
            set --local files (realpath $argv)

            for file in $files
                if test ! -f $file
                    echo "fishtape: Invalid file or file not found: \"$file\"" >&2
                    return 1
                end
            end

            set --local operators -{n,z,b,c,d,e,f,g,G,k,L,O,p,r,s,S,t,u,w,x}
            set --local expectations \
                "a non-zero length string" \
                "a zero length string" \
                "a block device" \
                "a character device" \
                "a directory" \
                "an existing file" \
                "a regular file" \
                "a file with the set-group-ID bit set" \
                "a file with same group ID as the current user" \
                "a file with the sticky bit set" \
                "a symbolic link" \
                "a file owned by the current user" \
                "a named pipe" \
                "a file marked as readable" \
                "a file of size greater than zero" \
                "a socket" \
                "a terminal tty file descriptor" \
                "a file with the set-user-ID bit set" \
                "a file marked as writable" \
                "a file marked as executable"

            set --universal _fishtape_test_number 0
            set --universal _fishtape_test_passed 0
            set --universal _fishtape_test_failed 0

            function @echo
                echo "# $argv"
            end

            function @test --argument-names name --inherit-variable operators --inherit-variable expectations
                set --erase argv[1]
                set --query argv[2] || set --append argv ""

                set _fishtape_test_number (math $_fishtape_test_number + 1)

                if test $argv
                    set _fishtape_test_passed (math $_fishtape_test_passed + 1)

                    echo "ok $_fishtape_test_number $name"
                else
                    if test $argv[1] = "!"
                        set operator "! "
                        set expected "not "
                        set --erase argv[1]
                    end

                    if set --query argv[3]
                        set operator "$operator"$argv[2]
                        set expected (string escape -- $argv[3])
                        set actual (string escape -- $argv[1])
                    else
                        set operator "$operator"$argv[1]
                        set expected "$expected"$expectations[(contains --index -- $argv[1] $operators)]
                        set actual (string escape -- $argv[2])
                    end

                    set _fishtape_test_failed (math $_fishtape_test_failed + 1)

                    status print-stack-trace |
                        string replace --filter --regex -- "\s+called on line (\d+) of file (.+)" '$2:$1' |
                        read --local at

                    echo "not ok $_fishtape_test_number $name"
                    echo "  ---"
                    echo "    operator: $operator"
                    echo "    expected: $expected"
                    echo "    actual: $actual"
                    echo "    at: $at"
                    echo "  ..."
                end
            end

            echo TAP version 13

            for file in $files
                fish --init-command=(functions @echo | string collect) --init-command=(functions @test | string collect) $file
            end

            echo
            echo "1..$_fishtape_test_number"
            echo "# pass $_fishtape_test_passed"
            test $_fishtape_test_failed -eq 0 &&
                echo "# ok" ||
                echo "# fail $_fishtape_test_failed"

            functions --erase @echo @test

            set --local failed $_fishtape_test_failed
            set --erase _fishtape_test_number
            set --erase _fishtape_test_passed
            set --erase _fishtape_test_failed

            test $failed -eq 0
    end
end
