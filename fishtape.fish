set -g fishtape_version 2.1.2

complete -c fishtape -n __fish_use_subcommand -a --help -d "Show usage help"
complete -c fishtape -n __fish_use_subcommand -a --version -d "$fishtape_version"

function fishtape -d "TAP-based test runner"
    if not isatty
        if not contains -- $argv @{test,mesg}
            set argv $argv -
        end
    end
    switch "$argv[1]"
        case {,-}-h{elp,} ""
            echo "usage: fishtape <files...>    Run tests in <files>"
            echo "       fishtape --help        Show this help"
            echo "       fishtape --version     Show the current version"
            echo "examples:"
            echo "       fishtape <test.fish"
            echo "       fishtape test/*.fish"
            echo "       fish -c \"fishtape test/*.fish\" | tap-nyan"
        case {,-}-v{ersion,}
            echo "fishtape version $fishtape_version"
        case @mesg
            echo -s {$argv[2],mesg,$argv[3]}\t
        case @test
            if set -q argv[4]
                set -l rest (printf "%s\n" $argv[4..-1] | command awk '
                    BEGIN { i = 0 }
                    {
                        if (NR == 1 && $0 == "!") {
                            not = "!"
                        } else if (NR <= 2 && !operator && /^-(n|z|b|c|d|e|f|g|G|k|L|O|p|r|s|S|t|u|w|x)$/) {
                            operator = $0
                        } else if (NR > 1 && !i && !(not && NR == 2) && /^(!?=|-(eq|ne|gt|ge|lt|le))$/) {
                            a[i] = operator ? (a[i] ? a[i] " " : "") operator : a[i]
                            operator = $0
                            i++
                        } else {
                            a[i] = (a[i] ? a[i]" " : "") $0
                        }
                    }
                    END {
                        print not operator "\n" a[0] "\n" (i ? a[i]\
                            : operator == "-n" ? "a non-zero length string"\
                            : operator == "-z" ? "a zero length string"\
                            : operator == "-b" ? "a block device"\
                            : operator == "-c" ? "a character device"\
                            : operator == "-d" ? "a directory"\
                            : operator == "-e" ? "an existing file"\
                            : operator == "-f" ? "a regular file"\
                            : operator == "-g" ? "a file with the set-group-ID bit set"\
                            : operator == "-G" ? "a file with same group ID as the current user"\
                            : operator == "-L" ? "a symbolic link"\
                            : operator == "-O" ? "a file owned by the current user"\
                            : operator == "-p" ? "a named pipe"\
                            : operator == "-r" ? "a file marked as readable"\
                            : operator == "-s" ? "a file of size greater than zero"\
                            : operator == "-S" ? "a socket"\
                            : operator == "-t" ? "a terminal tty file descriptor"\
                            : operator == "-u" ? "a file with the set-user-ID bit set"\
                            : operator == "-w" ? "a file marked as writable"\
                            : operator == "-x" ? "a file marked as executable"\
                            : "a valid operator") "\n"\
                            (not ? not "\n" : "") (i ? a[0] "\n" operator "\n" a[1] : operator "\n" a[0])
                    }
                ')
                if test $rest[4..-1] 2>/dev/null
                    echo -s {$argv[2],1,$argv[3]}\t
                else
                    echo -s {$argv[2],0,$argv[3],$rest[1],$rest[2],$rest[3]}\t
                end
                functions -q teardown; and teardown
            else
                echo -s {$argv[2],todo,$argv[3]\ \#\ TODO}\t
            end
        case \*
            set -l files (printf "%s\n" $argv | command awk -v PWD="$PWD" '
                /^-$/ {
                    print; next
                }
                {
                    n = split((/^\// ? "" : PWD "/") $0, tree, "/")
                    for (i = k = 0; ++i <= n; ) {
                        node = tree[i]
                        k += (_k = node == ".." ? k ? -1 : 0 : node && node != "." ? 1 : 0)
                        path[k] = _k > 0 ? node : path[k]
                    }
                    out = ""
                    for (i = 1; i <= k || !out; i++) {
                        out = out "/" path[i]
                    }
                    print out
                }
            ')

            for file in $files
                if test $file != - -a ! -f $file
                    echo "fishtape: can't open file \"$file\" -- is this a valid file?"
                    return 1
                end
            end

            set -l tmp (random)

            command awk '
                FNR == 1 {
                    print (NR > 1 ? end_batch() ";" : "") begin_batch()
                    id++
                }
                !/^[ \t\r\n\f\v]*#/ && $0 {
                    gsub(/\'/, "\\\\\'")
                    gsub(/\$current_dirname/, d[split(FILENAME, d, /\/[^\/]*$/) - 1])
                    gsub(/\$current_filename/, f[split(FILENAME, f, "/")])
                    sub(/^[ \t\r\n\f\v]*@mesg/, "fishtape @mesg " id)
                    sub(/^[ \t\r\n\f\v]*@test/, "functions -q setup; and setup; true; fishtape @test " id)
                    print
                }
                END {
                    print end_batch() ";while for j in $jobs;contains -- $j " jobs() ";and break;end;end"
                }
                function begin_batch() {
                    return "fish -c \'"
                }
                function end_batch() {
                    return "echo " id "\'&;set -l jobs $jobs " jobs(" -l")
                }
                function jobs(opt) {
                    return "(jobs" opt " | command awk \'/^[0-9]+\\\t/ { print $1 }\')"
                }
            ' $files >@fishtape$tmp

            fish @fishtape$tmp | command awk -F\t '
                BEGIN {
                    print "TAP version 13"
                }
                NF == 1 {
                    for (i = 0; i < count[$1]; i++) {
                        print\
                            (mesg = batch[$1 i "mesg"])\
                            ? mesg : sub(/ok/, "ok " ++total, batch[$1 i])\
                            ? batch[$1 i] ((error = batch[$1 i "error"]) && ++failed ? "\n" error : "") : ""
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
                        batch[id "error"] =\
                            "  ---\n"\
                            "    operator: "$4 "\n"\
                            "    expected: "$6 "\n"\
                            "    actual:   "$5 "\n"\
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

            set -l _status $status
            command rm -f @fishtape$tmp
            return $_status
    end
end
