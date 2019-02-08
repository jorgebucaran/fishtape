set -g fishtape_version 2.0.0

complete -xc fishtape -n __fish_use_subcommand -a --help -d "Show usage help"
complete -xc fishtape -n __fish_use_subcommand -a --version -d "$fishtape_version"

function fishtape -d "TAP-based test runner"
    if not isatty
        if not contains -- $argv @{test,mesg}
            set argv $argv -
        end
    end
    switch "$argv[1]"
        case @mesg
            echo -e "$argv[2]\tmesg\t$argv[3..-1]"
        case @test
            if set -q argv[4]
                set -l rest (printf "%s\n" $argv[-1..3] | command awk '
                    {
                        args[i++] = $0
                    }
                    END {
                        right = args[0]
                        left = is_binary(operator = args[1]) ? args[2] : ""
                        is = args[i = (left || (left == 0) ? 3 : 2)] == "!" ? "!" : ""
                        print\
                            args[is ? ++i : i] "\n"\
                            left "\n" \
                            (is ? is" " : "") operator "\n"\
                            right "\n"\
                            (is ? is"\n" : "") (""left ? left"\n" : "") operator "\n" right
                    }
                    function is_binary(s) {
                        return s ~ /^(!?=|-(eq|ne|gt|ge|lt|le))$/
                    }
                ')
                if test $rest[5..-1]
                    echo -s {$argv[2],1,$rest[1]}\t
                else
                    echo -s {$argv[2],0,$rest[1],$rest[2],$rest[3],$rest[4]}\t
                end
                functions -q teardown; and teardown
            else
                echo -s {$argv[2],todo,$argv[3]\ \#\ TODO}\t
            end
        case {,-}-v{ersion,}
            echo "fishtape version $fishtape_version"
        case {,-}-h{elp,} ""
            echo "usage: fishtape <files...>    Run tests in <files>"
            echo "       fishtape --help        Show this help"
            echo "       fishtape --version     Show the current version"
            echo "examples:"
            echo "       fishtape <test.fish"
            echo "       fishtape test/*.fish"
            echo "       fish -c \"fishtape test/*.fish\" | tap-nyan"
        case \*
            for f in $argv
                if test $f != - -a ! -f $f
                    echo "fishtape: can't open file \"$f\" -- is this a valid file?"
                    return 1
                end
            end
            command awk '
                FNR == 1 {
                    print (NR > 1 ? end()";" : "") "fish -c \'"
                    id++
                }
                !/^[[:space:]]*#/ && $0 {
                    gsub(/\'/, "\\\\\'")
                    sub(/\$filename/, f[split(FILENAME, f, "/")])
                    sub(/^[[:space:]]*@mesg/, "fishtape @mesg " id)
                    sub(/^[[:space:]]*@test/, "functions -q setup; and setup; fishtape @test " id)
                    print
                }
                END {
                    print end()wait()
                }
                function end() {
                    return "echo " id "\'&;set -l js $js " jobs(" -l")
                }
                function wait() {
                    return ";while for j in $js;contains -- $j "jobs()";and break;end;end"
                }
                function jobs(opt) {
                    return "(jobs"opt" | command awk \'/^[0-9]+\\\t/ { print $1 }\')"
                }
            ' $argv | fish -c source | command awk -F\t '
                BEGIN {
                    print "TAP version 13"
                }
                NF == 1 {
                    for (i = 0; i < count[$1]; i++) {
                        print\
                            (mesg = batch[$1 i "mesg"])\
                            ? mesg\
                            : sub(/ok/, "ok " ++total, batch[$1 i])\
                            ? batch[$1 i] ((error = batch[$1 i "error"]) && ++failed ? "\n" error : "")\
                            : ""
                        todo = (batch[$1 i "todo"]) ? todo + 1 : todo
                        fflush()
                    }
                }
                NF > 1 {
                    id = $1 count[$1]++
                    if ($2 == "mesg") {
                        batch[id $2] = "# " $3
                    } else if ($2) {
                        batch[id] = batch[id $2] = "ok " $3
                    } else {
                        batch[id] = "not ok " $3
                        is = (split($5, ops, " ") && ops[1] == "!" && ($5 = ops[2])) ? "not " : ""
                        $4 = $4 ? $4\
                            : $5 == "-n" \
                            ? is "a zero length string" \
                            : $5 == "-z" \
                            ? is "a non-zero length string" \
                            : $5 == "-b" \
                            ? is "a block device" \
                            : $5 == "-c" \
                            ? is "a character device" \
                            : $5 == "-d" \
                            ? is "a directory" \
                            : $5 == "-e" \
                            ? is "an existing file" \
                            : $5 == "-f" \
                            ? is "a regular file" \
                            : $5 == "-g" \
                            ? is "a file with the set-group-ID bit set" \
                            : $5 == "-G" \
                            ? is "a file with same group ID as the current user" \
                            : $5 == "-L" \
                            ? is "a symbolic link" \
                            : $5 == "-O" \
                            ? is "a file owned by the current user" \
                            : $5 == "-p" \
                            ? is "a named pipe" \
                            : $5 == "-r" \
                            ? is "a file marked as readable" \
                            : $5 == "-s" \
                            ? is "a file of size greater than zero" \
                            : $5 == "-S" \
                            ? is "a socket" \
                            : $5 == "-t" \
                            ? is "a terminal tty file descriptor" \
                            : $5 == "-u" \
                            ? is "a file with the set-user-ID bit set" \
                            : $5 == "-w" \
                            ? is "a file marked as writable" \
                            : $5 == "-x" \
                            ? is "a file marked as executable" \
                            : $4
                        batch[id "error"] =\
                            "  ---\n"\
                            "    operator: "(is ? "!" : "")$5"\n"\
                            "    expected: "$4"\n"\
                            "    actual:   "($6 == "" ? "\"\"" : $6)"\n"\
                            "  ..."
                    }
                }
                END {
                    print "\n1.." total
                    print "# pass " (total - failed - todo)

                    if (failed) print "# fail " failed
                    if (todo) print "# todo " todo
                    else if (!failed) print "# ok"
                    
                    exit (failed > 0)
                }
            '
    end
end
