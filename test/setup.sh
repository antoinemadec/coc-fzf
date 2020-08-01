#!/usr/bin/env bash

set -e

git clone http://github.com/antoinemadec/test

sed "s#__COCFZFDIR__#$(readlink -e ..)#" vimrc_default.tpl > vimrc_default

nvim -u vimrc_default -c "PlugInstall | PlugUpdate | qa"
