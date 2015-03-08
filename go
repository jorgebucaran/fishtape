#!/usr/bin/env sh
#/
# goget is a universal shell script that downloads, compiles and sets up Go
# from source on your system. Want to start with go, but don't know where?
# Just `curl -L git.io/getgo | sh`.

# One-line exit utility.
die() {
  echo $1
  exit 1
}

# Check if a program exists in the system.
has() {
  type "$1" >/dev/null 2>&1
}

osx() {
  [ "$(uname)" = "Darwin" ]
}

em() {
  switch_color="\033["
  normal_color="${switch_color}0m"
  gray_color="${switch_color}1;36m"
  echo "${gray_color}$1${normal_color}"
}

getgo() {
  if osx; then
    # Use every osx's default git installation.
    has git || alias git="xcrun git"
  else
    has git || die "✘: You need git to install go.
    Please visit http://git-scm.com/downloads"
  fi

  if [ -z "$GOURL" ]; then
    GOURL="https://go.googlesource.com/go"
  fi

  DEFAULT_ROOT="/usr/local/go"

  if [ -z "$GOROOT" ]; then
    GOROOT="$DEFAULT_ROOT"
  fi

  root=$(dirname "$GOROOT")

  if [ ! -w "$root" ]; then
    die "✘ $USER does not own $root. Change permissions,
    try a different directory, or use sudo if you must."
  fi

  # Use $SKIP to skip over the installation.
  if [ "$SKIP" != true ]; then
    # There is a directory conflict, create a backup and go on.
    if [ -d "$GOROOT" ]; then
      goroot_bak=$(mktemp -d "$GOROOT"_bak_XXXX)
      mv "$GOROOT" "$goroot_bak"
    fi

    git clone "$GOURL" "$GOROOT"
    cd "$GOROOT"

    if [ -z "$GOTAG" ]; then
      GOTAG=go1.4.1
    fi

    git checkout "$GOTAG"

    if [ ! -e src/all.bash ]; then
      die "✘: all.bash could not be found. So long!"
    fi

    cd src
    ./all.bash

    echo # Make go available right away.
    echo "Appending $GOROOT/bin to \$PATH"
    PATH=$PATH:"$GOROOT/bin"

    # $GOROOT is compiled / embedded in the go binary, so it should only
    # be exported if you move the go's directory to a different location
    # after the installation.

    echo
    echo "Add to your .profile     "
    em   "  PATH=\$PATH:$GOROOT/bin"
    echo
    echo "or fish.config           "
    em   "  set PATH \$PATH $GOROOT/bin"

    # Setting GOPATH affects the way the go tool. Export GOPATH manually
    # for each application to customize dependency versions, etc.

    echo
    echo "You should also set \$GOPATH to your preferred location."
    em   "  export GOPATH=\$HOME/go"
    em   "  PATH=\$PATH:\$GOPATH/bin"
    echo
    echo "or fish.config               "
    em   "  set -x GOPATH \$HOME/go    "
    em   "  set PATH \$PATH \$GOPATH/bin"
    echo
  fi

  if [ -z "${GOPATH+_}" ]; then
    # Use our custom location if GOPATH is not set.
    # Note we export GOHOME here so that it is visible to go tool.
    export GOPATH="$HOME/go"
  fi

  if [ -z "$GOPATH" ]; then
    # Use an empty string to skip GOPATH setup.
    exit 0
  fi

  # Create $GOPATH and base workspace based in github.user if defined.
  if [ "$GOPATH" = "$GOROOT" ]; then
    die "✘: \$GOPATH can't be the same as \$GOROOT"
  else
    if [ -d "$GOPATH" ]; then
      echo "✘: $GOPATH directory already exists."
    else
      echo "Creating go workspace in $GOPATH"
      mkdir -p "$GOPATH"

      gh_user=$(git config github.user)
      if [ -n "$gh_user" ]; then
        base_path="$GOPATH/src/github.com/$gh_user"

        echo "Creating $gh_user's base path at $base_path"
        mkdir -p "$base_path"

        echo "Adding 'hello' sample project."
        mkdir -p "$base_path/hello"
        if curl -sfL "git.io/hello-go" > "$base_path/hello/hello.go"; then
          # go tool finds the source code by looking for the $base_path/hello
          # package inside the workspace specified by GOPATH
          if go install "github.com/$gh_user/hello"; then
            "$GOPATH/bin/hello"
          fi
        fi
      fi
    fi
  fi
}
getgo
