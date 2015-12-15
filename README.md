<p align="center">
  <a href="http://github.com/fisherman/fishtape">
    <img alt="Fishtape" width=420px  src="https://cloud.githubusercontent.com/assets/8317250/11809776/879a9290-a36c-11e5-92a2-1a0d4d52d753.png">
  </a>
</p>


[![][travis-badge]][travis-link]

## About

Fishtape is a [TAP][tap] producer and test harness for [fish][fish]. Fishtape scans one or more fish files and executes _test blocks_ producing a TAP stream.

## Install

```fish
git clone https://github.com/fisherman/fishtape
cd fishtape
make install
```

With [Fisherman][fisherman]:

```fish
fisher install fishtape
```


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


## Help

Install the `man` pages:

```fish
cd fishtape
make doc
```

See [`fishtape(1)`][fishtape-1] and [`fishtape(7)`][fishtape-7]. For questions and feedback join the [Gitter room][wharf] or browse the [issues][issues].


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
