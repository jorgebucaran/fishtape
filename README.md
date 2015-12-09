<br>
<div align="center">
  <a href="http://github.com/fisherman/fishtape">
    <img width=350px  src="https://cloud.githubusercontent.com/assets/8317250/11613543/30c17c3c-9c68-11e5-8432-d321b2296e0a.png">
  </a>
</div>


[![][travis-badge]][travis-link]

## About

Fishtape is a [TAP][tap] producer and test harness for [fish][fish]. Fishtape scans one or more fish files and executes _test blocks_ producing a TAP stream.

## Install

```fish
git clone https://github.com/fisherman/fishtape
cd fishtape
make install
```

See [wiki][wiki] for more install options.

## Usage

### Writing Tests

Test files are fish files with one or more test blocks.

```fish
test "current directory is home"
  $HOME = $DIRNAME
end

test "math still works"
  42 -eq (math 41 + 1)
end

test "test is a builtin"
  "test" = (builtin -n)
end

test "no odds are evens"
  1 3 5 7 != (
    for i in (seq $n)
      if test (math $i%2) = 0
        echo $i
      end
    end)
end
```

### Running Tests

Fishtape reads the specified files, or the standard input if no files are given, and converts test blocks into valid fish syntax which is then evaluated, producing a TAP stream.

```fish
fishtape path/to/tests/*.fish
```

### Microbenchmarks

You can measure average execution speed between functions and/or other utilities using `--time=<function>[,...]`.

This can be useful when trying to compare two or more ways to do the same thing, and we want to see which one is possibly faster.

```fish
fishtape --time=func{1,2,3}
```

Fishtape will use any available standard input for arguments when invoking each of the given functions:

```fish
fishtape --time=bubble,heap,qsort < numbers
```

## Help

Install the `man` pages:

```fish
cd fishtape
make doc
```

See [`fishtape(1)`][fishtape-1] and [`fishtape(7)`][fishtape-7]. For questions and feedback join us at the [Wharf][wharf] or browse the [issue][issues] tracker.


<!-- Links -->
[tap]:          http://testanything.org/
[fish]:         http://fishshell.com/
[wharf]:        https://gitter.im/fisherman/wharf
[issues]:       https://github.com/fisherman/fishtape/issues
[wiki]:         https://github.com/fisherman/fishtape/wiki
[fishtape-1]:   man/man1/fishtape.md
[fishtape-7]:   man/man7/fishtape.md
[fisherman]:    http://github.com/fisherman/fisherman
[travis-link]:  https://travis-ci.org/fisherman/fishtape
[travis-badge]: https://img.shields.io/travis/fisherman/fishtape.svg?style=flat-square
