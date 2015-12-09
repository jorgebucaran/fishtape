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

# A single test block consists of a pair of test/end keywords
# with matching indentation. Allows you to write tests inside
# fish loops, conditionals, etc.

test && /^ *end$/ && (indent == index($0, "end")) {
  test = 0

  printf("\n")
  print count

  printf("fishtape_restore_globals\n")
  print teardown

  next
}

{ print }
