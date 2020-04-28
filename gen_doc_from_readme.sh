#!/usr/bin/env bash

set -e

FILENAME="$(basename $PWD).txt"

# setup
git clone https://github.com/xolox/vim-tools.git || true
cd vim-tools
virtualenv --python=python2 html2vimdoc
html2vimdoc/bin/pip install beautifulsoup coloredlogs markdown

# fix Beatiful Soup error
sed -i "s/logger.addHandler(coloredlogs.ColoredStreamHandler(show_name=True))/coloredlogs.install(level='DEBUG')/" *.py

# gen vim doc
html2vimdoc/bin/python ./html2vimdoc.py --file=$FILENAME ../README.md > ../doc/$FILENAME

# hack the commands table
cd ../doc
sed -i 's/| Command | List |/| Command | List |~\n/' $FILENAME
sed -i 's/ | --- | --- | //' $FILENAME
sed -i "s/'\(:[^:]*\)'/\`\1\`/g" $FILENAME
echo "INFO: please align vimdoc's Commands table manually"
