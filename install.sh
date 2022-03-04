#!/bin/bash

#############################################
# IMPORTANT NOTE                            #
#                                           #
# This install script should be copied to   # 
# the public repository Echo360/tap-install #
# so that it can be downloaded without      #
# requiring the user to create a GitHub     #
# Personal Access Token.                    #
#                                           #
#############################################


set -u

abort() {
  printf "%s\n" "$@"
  exit 1
}

# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
# shellcheck disable=SC2292
if [ -z "${BASH_VERSION:-}" ]
then
  abort "Bash is required to interpret this script."
fi

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

ring_bell() {
  # Use the shell's audible bell.
  if [[ -t 1 ]]
  then
    printf "\a"
  fi
}

# First check that Homebrew is installed
if ! command -v brew >/dev/null 2>&1
then
  abort "Homebrew is required to install this software. Please install Homebrew first."
fi


ohai "Installing echo360/tap from GitHub"

execute "brew" "tap" "echo360/tap" "git@github.com:Echo360/homebrew-tap.git"
execute "command" "brew" "update" "--force" "--quiet"

ohai "Installation successful!"
echo
ring_bell

ohai "Next steps, install some stuff!"
echo
# Check that jq is installed
if command -v jq >/dev/null 2>&1
then
  command brew tap-info echo360/tap --json | command jq -r '.[]|(.formula_names[],.cask_tokens[])'
else
  ohai "Check the README for available formulas. https://github.com/Echo360/homebrew-tap/blob/main/README.md"
fi
echo