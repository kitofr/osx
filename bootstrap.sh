#!/bin/bash
xcode-select --install
exec bash

git clone https://github.com/Intelliplan/osx.git
cd osx
./.osx
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
cp .bash_profile .
exec bash
brew bundle
