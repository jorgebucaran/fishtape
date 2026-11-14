function fishtape --description "A test runner for Fish"
    switch "$argv"
        case -v --version
            echo "fishtape, version 3.0.1"
        case "" -h --help
            echo "Usage: fishtape <files...>  Run test files"
            echo "Options:"
            echo "       -v, --version  Print version"
            echo "       -h, --help     Print this help message"
        case \*
            if set --local invalid (path filter --invert --type file -- $argv)
                echo "fishtape: Not a file: \"$invalid[1]\"" >&2 && return 1
            end

            set --local total 0
            set --local failed 0
            set --local fish_path (status fish-path)

            echo "TAP version 14"

            for file in $argv
                set --local temp (command mktemp -d)
                command mkdir $temp/{home,tmp,run}
                printf "%s\n" $total $failed >$temp/result

                $fish_path --no-config --no-execute -- $file &&
                    HOME=$temp/home TMPDIR=$temp/tmp XDG_RUNTIME_DIR=$temp/run XDG_CONFIG_HOME=$temp/config \
                        XDG_DATA_HOME=$temp/data XDG_STATE_HOME=$temp/state XDG_CACHE_HOME=$temp/cache \
                        $fish_path (status filename) (path resolve -- $file) $temp/result

                set --local code $status
                read --line total failed done <$temp/result
                command rm -rf $temp

                if test -z "$done"
                    set total (math $total + 1)
                    set failed (math $failed + 1)
                    echo "not ok $total "(string replace --all --regex -- '[\\\\#]' '\\\\$0' $file)
                    echo "  ---"
                    echo "    message: \"exited with status $code before the end of the file\""
                    echo "  ..."
                end
            end

            echo
            echo "1..$total"
            echo "# pass "(math $total - $failed)
            test $failed -eq 0 && echo "# ok" || echo "# fail $failed"
            test $failed -eq 0
    end
end

set --query argv[1] || return 0

set --global _fishtape_result $argv[2]

begin
    set --local plugin (path dirname (path dirname $argv[1]))
    set --prepend fish_function_path $plugin/functions
    set --prepend fish_complete_path $plugin/completions

    for conf in $plugin/conf.d/*.fish
        source $conf
    end
end

function @echo
    echo "# $argv"
end

function @test --argument-names description
    set --erase argv[1]
    set --local expression (string escape -- $argv)
    set --query argv[2] || set --append argv "" # emulates test-require-arg
    read --line --local total failed <$_fishtape_result
    set total (math $total + 1)
    set description (string replace --all --regex -- '[\\\\#]' '\\\\$0' $description)

    if test $argv
        echo "ok $total $description"
    else
        set failed (math $failed + 1)
        set --local operator $argv[2]

        if test "$argv[1]" = !
            set --erase argv[1]
            set operator "! $argv[2]"
        end

        set --local expected $argv[3]
        set --local actual $argv[1]
        set --local keys operator expected actual
        test (count $argv) = 3 || set keys expression

        LC_ALL=C status print-stack-trace |
            string replace --filter --regex -- '^\s+called on line (\d+) of file (.+)$' '$2:$1' | read --local at

        echo "not ok $total $description"
        echo "  ---"

        for key in $keys at
            set --local value "$$key"

            if string match --quiet -- \*\n\* $value && ! string match --quiet --regex -- '(?!\n)[[:cntrl:]]|\n$' $value
                set --local indent (string match --quiet -- ' *' $value && echo 2)
                echo "    $key: |$indent-"
                printf "      %s\n" (string split -- \n $value)
            else
                set value (string replace --all --regex -- '[\\\\"]' '\\\\$0' $value |
                    string replace --all -- \e '\e' | string replace --all -- \t '\t' | string join '\n')

                for char in (string match --all --regex -- '[[:cntrl:]]' $value)
                    set value (string replace --all -- $char '\x'(printf %02X "'$char") $value)
                end

                echo "    $key: \"$value\""
            end
        end

        echo "  ..."
    end

    printf "%s\n" $total $failed >$_fishtape_result
end

function exit
    set --local code $argv $status
    set --local sources (LC_ALL=C status print-stack-trace | string match -- 'from sourcing file *')
    set --query sources[2] || set --global _fishtape_exit $code[1]
    builtin exit $code[1]
end

source $argv[1]
set --query _fishtape_exit && builtin exit $_fishtape_exit
echo done >>$_fishtape_result
